import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/ollama_client.dart';
import '../../../../core/network/sse_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDatasource localDatasource;
  final SseClient sseClient;
  final OllamaClient ollamaClient;
  final FlutterSecureStorage secureStorage;

  ChatRepositoryImpl({
    required this.localDatasource,
    required this.sseClient,
    required this.ollamaClient,
    required this.secureStorage,
  });

  @override
  Future<Result<List<Conversation>>> getConversationsForSubject(
      String subjectId) async {
    try {
      final models =
          await localDatasource.getConversationsForSubject(subjectId);
      return Success(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<Conversation>> getConversation(String conversationId) async {
    try {
      final model = await localDatasource.getConversation(conversationId);
      final messages = await localDatasource.getMessages(conversationId);
      return Success(model.toEntity().copyWith(
            messages: messages.map((m) => m.toEntity()).toList(),
          ));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<Conversation>> createConversation({
    required String subjectId,
    required String title,
    ConversationType type = ConversationType.chat,
  }) async {
    try {
      final model = await localDatasource.createConversation(
        subjectId: subjectId,
        title: title,
        type: type == ConversationType.quizSession ? 'quiz_session' : 'chat',
      );
      return Success(model.toEntity());
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteConversation(String conversationId) async {
    try {
      await localDatasource.deleteConversation(conversationId);
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<Message>> saveMessage({
    required String conversationId,
    required String role,
    required String content,
  }) async {
    try {
      final model = await localDatasource.saveMessage(
        conversationId: conversationId,
        role: role,
        content: content,
      );
      return Success(model.toEntity());
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  /// Resolve the current provider from secure storage.
  Future<AiProvider> _getProvider() async {
    final providerStr =
        await secureStorage.read(key: AppConstants.apiProviderKey);
    return switch (providerStr) {
      'openai' => AiProvider.openai,
      'ollama' => AiProvider.ollama,
      _ => AiProvider.anthropic,
    };
  }

  @override
  Stream<String> streamResponse({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async* {
    final provider = await _getProvider();

    switch (provider) {
      case AiProvider.anthropic:
      case AiProvider.openai:
        final apiKey =
            await secureStorage.read(key: AppConstants.apiKeyKey);
        if (apiKey == null || apiKey.isEmpty) {
          throw const ApiKeyException(
              'Brak klucza API. Skonfiguruj go w ustawieniach.');
        }
        yield* sseClient.streamCompletion(
          systemPrompt: systemPrompt,
          messages: messages,
          provider: provider,
          apiKey: apiKey,
        );

      case AiProvider.ollama:
        final baseUrl = await secureStorage.read(
                key: AppConstants.ollamaBaseUrlKey) ??
            ApiConstants.ollamaDefaultBaseUrl;
        final model = await secureStorage.read(
                key: AppConstants.ollamaModelKey) ??
            '';
        debugPrint('[ChatRepo] Ollama: baseUrl=$baseUrl model="$model"');
        if (model.isEmpty) {
          throw const ApiKeyException(
              'Brak wybranego modelu Ollama. Skonfiguruj go w ustawieniach.');
        }
        yield* ollamaClient.streamCompletion(
          baseUrl: baseUrl,
          model: model,
          systemPrompt: systemPrompt,
          messages: messages,
        );
    }
  }

  @override
  Future<Result<String>> getApiKey() async {
    final provider = await _getProvider();
    if (provider == AiProvider.ollama) {
      // Ollama doesn't need an API key
      return const Success('ollama-local');
    }
    final key = await secureStorage.read(key: AppConstants.apiKeyKey);
    if (key == null || key.isEmpty) {
      return const Error(
          ApiKeyFailure('Brak klucza API. Skonfiguruj go w ustawieniach.'));
    }
    return Success(key);
  }

  @override
  Future<Result<List<Message>>> getMessages(String conversationId) async {
    try {
      final models = await localDatasource.getMessages(conversationId);
      return Success(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }
}
