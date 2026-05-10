import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'dio_client.dart';

class SseClient {
  final DioClient _dioClient;

  SseClient(this._dioClient);

  Stream<String> streamCompletion({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    required AiProvider provider,
    required String apiKey,
  }) async* {
    switch (provider) {
      case AiProvider.anthropic:
        yield* _streamAnthropic(systemPrompt, messages, apiKey);
      case AiProvider.openai:
        yield* _streamOpenAi(systemPrompt, messages, apiKey);
      case AiProvider.ollama:
        throw UnsupportedError('Ollama uses OllamaClient, not SseClient');
    }
  }

  Stream<String> _streamAnthropic(
    String systemPrompt,
    List<Map<String, String>> messages,
    String apiKey,
  ) async* {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.anthropicBaseUrl}/messages',
        data: {
          'model': ApiConstants.anthropicModel,
          'max_tokens': ApiConstants.maxResponseTokens,
          'system': systemPrompt,
          'messages': messages,
          'stream': true,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': ApiConstants.anthropicVersion,
            'content-type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr.trim() == '[DONE]') return;
            try {
              final data = json.decode(jsonStr) as Map<String, dynamic>;
              final type = data['type'] as String?;
              if (type == 'content_block_delta') {
                final delta = data['delta'] as Map<String, dynamic>?;
                final text = delta?['text'] as String?;
                if (text != null) yield text;
              }
            } catch (_) {}
          }
        }
      }
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error as Exception;
      throw ServerException(
        'Anthropic streaming error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Stream<String> _streamOpenAi(
    String systemPrompt,
    List<Map<String, String>> messages,
    String apiKey,
  ) async* {
    try {
      final allMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ];

      final response = await _dioClient.dio.post(
        '${ApiConstants.openAiBaseUrl}/chat/completions',
        data: {
          'model': ApiConstants.openAiModel,
          'messages': allMessages,
          'max_tokens': ApiConstants.maxResponseTokens,
          'stream': true,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr.trim() == '[DONE]') return;
            try {
              final data = json.decode(jsonStr) as Map<String, dynamic>;
              final choices = data['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                final delta =
                    choices[0]['delta'] as Map<String, dynamic>?;
                final content = delta?['content'] as String?;
                if (content != null) yield content;
              }
            } catch (_) {}
          }
        }
      }
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error as Exception;
      throw ServerException(
        'OpenAI streaming error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Non-streaming completion for structured responses (JSON)
  Future<String> getCompletion({
    required String systemPrompt,
    required List<Map<String, dynamic>> messages,
    required AiProvider provider,
    required String apiKey,
  }) async {
    switch (provider) {
      case AiProvider.anthropic:
        return _getAnthropicCompletion(systemPrompt, messages, apiKey);
      case AiProvider.openai:
        return _getOpenAiCompletion(systemPrompt, messages, apiKey);
      case AiProvider.ollama:
        throw UnsupportedError('Ollama uses OllamaClient, not SseClient');
    }
  }

  Future<String> _getAnthropicCompletion(
    String systemPrompt,
    List<Map<String, dynamic>> messages,
    String apiKey,
  ) async {
    final response = await _dioClient.post(
      '${ApiConstants.anthropicBaseUrl}/messages',
      data: {
        'model': ApiConstants.anthropicModel,
        'max_tokens': ApiConstants.maxResponseTokens,
        'system': systemPrompt,
        'messages': messages,
      },
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': ApiConstants.anthropicVersion,
        'content-type': 'application/json',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    return content.first['text'] as String;
  }

  Future<String> _getOpenAiCompletion(
    String systemPrompt,
    List<Map<String, dynamic>> messages,
    String apiKey,
  ) async {
    final allMessages = [
      {'role': 'system', 'content': systemPrompt},
      ...messages,
    ];

    final response = await _dioClient.post(
      '${ApiConstants.openAiBaseUrl}/chat/completions',
      data: {
        'model': ApiConstants.openAiModel,
        'messages': allMessages,
        'max_tokens': ApiConstants.maxResponseTokens,
      },
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    return choices.first['message']['content'] as String;
  }
}
