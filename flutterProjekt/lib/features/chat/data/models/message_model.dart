import '../../domain/entities/message.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'role': role,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  Message toEntity() => Message(
        id: id,
        conversationId: conversationId,
        role: role,
        content: content,
        createdAt: createdAt,
      );
}
