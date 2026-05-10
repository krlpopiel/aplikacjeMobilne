import '../../../../core/utils/result.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Result<List<Conversation>>> getConversationsForSubject(
      String subjectId);
  Future<Result<Conversation>> getConversation(String conversationId);
  Future<Result<Conversation>> createConversation({
    required String subjectId,
    required String title,
    ConversationType type = ConversationType.chat,
  });
  Future<Result<void>> deleteConversation(String conversationId);
  Future<Result<Message>> saveMessage({
    required String conversationId,
    required String role,
    required String content,
  });
  Future<Result<List<Message>>> getMessages(String conversationId);
  Stream<String> streamResponse({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  });
  Future<Result<String>> getApiKey();
}
