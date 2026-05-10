import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/sse_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDatasource localDatasource;
  final SseClient sseClient;
  final FlutterSecureStorage secureStorage;

  ChatRepositoryImpl({
    required this.localDatasource,
    required this.sseClient,
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

  @override
  Stream<String> streamResponse({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async* {
    final apiKey = await secureStorage.read(key: AppConstants.apiKeyKey);
    final providerStr =
        await secureStorage.read(key: AppConstants.apiProviderKey);

    if (apiKey == null || apiKey.isEmpty) {
      throw const ApiKeyException(
          'Brak klucza API. Skonfiguruj go w ustawieniach.');
    }

    final provider = providerStr == 'openai'
        ? AiProvider.openai
        : AiProvider.anthropic;

    yield* sseClient.streamCompletion(
      systemPrompt: systemPrompt,
      messages: messages,
      provider: provider,
      apiKey: apiKey,
    );
  }

  @override
  Future<Result<String>> getApiKey() async {
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
