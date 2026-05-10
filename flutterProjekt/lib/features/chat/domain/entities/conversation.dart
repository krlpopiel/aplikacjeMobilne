import 'package:equatable/equatable.dart';
import 'message.dart';

enum ConversationType { chat, quizSession }

class Conversation extends Equatable {
  final String id;
  final String subjectId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;
  final ConversationType type;

  const Conversation({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.type = ConversationType.chat,
  });

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<Message>? messages,
  }) {
    return Conversation(
      id: id,
      subjectId: subjectId,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      type: type,
    );
  }

  @override
  List<Object?> get props =>
      [id, subjectId, title, createdAt, updatedAt, type, messages];
}
