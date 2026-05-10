import '../../../../core/utils/result.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessageStream {
  final ChatRepository repository;
  SendMessageStream(this.repository);

  Stream<String> call({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) =>
      repository.streamResponse(
        systemPrompt: systemPrompt,
        messages: messages,
      );
}

class GetConversationHistory {
  final ChatRepository repository;
  GetConversationHistory(this.repository);

  Future<Result<List<Message>>> call(String conversationId) =>
      repository.getMessages(conversationId);
}

class ClearConversation {
  final ChatRepository repository;
  ClearConversation(this.repository);

  Future<Result<void>> call(String conversationId) =>
      repository.deleteConversation(conversationId);
}
