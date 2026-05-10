import '../../domain/entities/conversation.dart';

class ConversationModel {
  final String id;
  final String subjectId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;

  ConversationModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      type: json['type'] as String? ?? 'chat',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'type': type,
      };

  Conversation toEntity() => Conversation(
        id: id,
        subjectId: subjectId,
        title: title,
        createdAt: createdAt,
        updatedAt: updatedAt,
        type: type == 'quiz_session'
            ? ConversationType.quizSession
            : ConversationType.chat,
      );
}
