import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

class ChatLocalDatasource {
  final Uuid _uuid = const Uuid();

  Box get _conversationsBox => Hive.box(AppConstants.conversationsBox);
  Box get _messagesBox => Hive.box(AppConstants.messagesBox);

  Future<List<ConversationModel>> getConversationsForSubject(
      String subjectId) async {
    try {
      final convs = <ConversationModel>[];
      for (final key in _conversationsBox.keys) {
        final json =
            Map<String, dynamic>.from(_conversationsBox.get(key) as Map);
        final model = ConversationModel.fromJson(json);
        if (model.subjectId == subjectId) convs.add(model);
      }
      convs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return convs;
    } catch (e) {
      throw CacheException('Failed to load conversations: $e');
    }
  }

  Future<ConversationModel> getConversation(String id) async {
    try {
      final data = _conversationsBox.get(id);
      if (data == null) throw const CacheException('Conversation not found');
      return ConversationModel.fromJson(
          Map<String, dynamic>.from(data as Map));
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to load conversation: $e');
    }
  }

  Future<ConversationModel> createConversation({
    required String subjectId,
    required String title,
    String type = 'chat',
  }) async {
    try {
      final now = DateTime.now();
      final model = ConversationModel(
        id: _uuid.v4(),
        subjectId: subjectId,
        title: title,
        createdAt: now,
        updatedAt: now,
        type: type,
      );
      await _conversationsBox.put(model.id, model.toJson());
      return model;
    } catch (e) {
      throw CacheException('Failed to create conversation: $e');
    }
  }

  Future<void> deleteConversation(String id) async {
    try {
      await _conversationsBox.delete(id);
      // Delete all messages for this conversation
      final keysToDelete = <dynamic>[];
      for (final key in _messagesBox.keys) {
        final json = Map<String, dynamic>.from(_messagesBox.get(key) as Map);
        if (json['conversationId'] == id) keysToDelete.add(key);
      }
      await _messagesBox.deleteAll(keysToDelete);
    } catch (e) {
      throw CacheException('Failed to delete conversation: $e');
    }
  }

  Future<MessageModel> saveMessage({
    required String conversationId,
    required String role,
    required String content,
  }) async {
    try {
      final model = MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        role: role,
        content: content,
        createdAt: DateTime.now(),
      );
      await _messagesBox.put(model.id, model.toJson());

      // Update conversation's updatedAt
      final convData = _conversationsBox.get(conversationId);
      if (convData != null) {
        final conv = Map<String, dynamic>.from(convData as Map);
        conv['updatedAt'] = DateTime.now().toIso8601String();
        await _conversationsBox.put(conversationId, conv);
      }

      return model;
    } catch (e) {
      throw CacheException('Failed to save message: $e');
    }
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final messages = <MessageModel>[];
      for (final key in _messagesBox.keys) {
        final json = Map<String, dynamic>.from(_messagesBox.get(key) as Map);
        final model = MessageModel.fromJson(json);
        if (model.conversationId == conversationId) messages.add(model);
      }
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return messages;
    } catch (e) {
      throw CacheException('Failed to load messages: $e');
    }
  }
}
