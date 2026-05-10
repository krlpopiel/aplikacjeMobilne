import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../errors/exceptions.dart';

/// Streaming client for Ollama's NDJSON protocol (distinct from SSE).
/// Each response line is a standalone JSON object.
class OllamaClient {
  final Dio _dio;

  OllamaClient()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(minutes: 10),
          contentType: 'application/json',
        ));

  /// Build the messages payload for the Ollama API.
  List<Map<String, String>> _buildMessages(
    String systemPrompt,
    List<Map<String, String>> messages,
  ) {
    return [
      {'role': 'system', 'content': systemPrompt},
      ...messages,
    ];
  }

  /// Stream a chat completion from Ollama's /api/chat endpoint.
  /// On Flutter Web, falls back to non-streaming mode since XHR
  /// doesn't support response streaming.
  Stream<String> streamCompletion({
    required String baseUrl,
    required String model,
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async* {
    final allMessages = _buildMessages(systemPrompt, messages);

    // On web, use non-streaming fallback
    if (kIsWeb) {
      final result = await _nonStreamingChat(baseUrl, model, allMessages);
      yield result;
      return;
    }

    // Native platforms — use NDJSON streaming
    try {
      final response = await _dio.post(
        '$baseUrl/api/chat',
        data: {
          'model': model,
          'stream': true,
          'messages': allMessages,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // last line may be incomplete

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          try {
            final json = jsonDecode(line) as Map<String, dynamic>;
            final content = json['message']?['content'] as String?;
            final done = json['done'] as bool? ?? false;
            if (content != null && content.isNotEmpty) yield content;
            if (done) return;
          } catch (_) {
            // incomplete JSON line — skip
          }
        }
      }
    } on DioException catch (e) {
      _handleDioError(e, baseUrl);
    }
  }

  /// Non-streaming chat — works on all platforms including Flutter Web.
  Future<String> _nonStreamingChat(
    String baseUrl,
    String model,
    List<Map<String, String>> messages,
  ) async {
    try {
      debugPrint('[OllamaClient] POST $baseUrl/api/chat | model=$model | '
          'messages=${messages.length}');

      final response = await _dio.post(
        '$baseUrl/api/chat',
        data: {
          'model': model,
          'stream': false,
          'messages': messages,
        },
      );

      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return data['message']?['content'] as String? ?? '';
    } on DioException catch (e) {
      _handleDioError(e, baseUrl);
      return ''; // unreachable
    }
  }

  /// Non-streaming completion for structured responses (JSON).
  /// Public API used by flashcard/quiz generation.
  Future<String> getCompletion({
    required String baseUrl,
    required String model,
    required String systemPrompt,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chat',
        data: {
          'model': model,
          'stream': false,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...messages,
          ],
        },
      );

      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return data['message']?['content'] as String? ?? '';
    } on DioException catch (e) {
      _handleDioError(e, baseUrl);
      return ''; // unreachable
    }
  }

  Never _handleDioError(DioException e, String baseUrl) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw ServerException(
        'Nie można połączyć z Ollama pod adresem $baseUrl. '
        'Upewnij się, że Ollama jest uruchomiona (ollama serve).',
      );
    }

    // Extract error details from response body
    String details = e.message ?? 'Nieznany błąd';
    final responseData = e.response?.data;
    if (responseData != null) {
      try {
        final body = responseData is String
            ? jsonDecode(responseData)
            : responseData;
        if (body is Map<String, dynamic> && body['error'] != null) {
          details = body['error'].toString();
        }
      } catch (_) {
        details = responseData.toString();
      }
    }

    debugPrint('[OllamaClient] Error ${e.response?.statusCode}: $details');

    throw ServerException(
      'Ollama error (${e.response?.statusCode}): $details',
      statusCode: e.response?.statusCode,
    );
  }
}
