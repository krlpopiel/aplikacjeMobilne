import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Streaming client for Ollama's NDJSON protocol (distinct from SSE).
/// Each response line is a standalone JSON object.
class OllamaClient {
  final Dio _dio;

  OllamaClient() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(minutes: 10),
  ));

  /// Stream a chat completion from Ollama's /api/chat endpoint.
  Stream<String> streamCompletion({
    required String baseUrl,
    required String model,
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async* {
    try {
      final requestBody = {
        'model': model,
        'stream': true,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
      };

      final response = await _dio.post(
        '$baseUrl/api/chat',
        data: requestBody,
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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw ServerException(
          'Nie można połączyć z Ollama pod adresem $baseUrl. '
          'Upewnij się, że Ollama jest uruchomiona (ollama serve).',
        );
      }
      throw ServerException(
        'Ollama streaming error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Non-streaming completion for structured responses (JSON).
  Future<String> getCompletion({
    required String baseUrl,
    required String model,
    required String systemPrompt,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final requestBody = {
        'model': model,
        'stream': false,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
      };

      final response = await _dio.post(
        '$baseUrl/api/chat',
        data: requestBody,
      );

      final data = response.data as Map<String, dynamic>;
      return data['message']?['content'] as String? ?? '';
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw ServerException(
          'Nie można połączyć z Ollama pod adresem $baseUrl. '
          'Upewnij się, że Ollama jest uruchomiona (ollama serve).',
        );
      }
      throw ServerException(
        'Ollama completion error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
