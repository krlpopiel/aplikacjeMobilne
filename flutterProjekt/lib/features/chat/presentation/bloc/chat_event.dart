import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversation extends ChatEvent {
  final String? conversationId;
  final String subjectId;
  const LoadConversation({this.conversationId, required this.subjectId});
  @override
  List<Object?> get props => [conversationId, subjectId];
}

class SendMessage extends ChatEvent {
  final String content;
  const SendMessage(this.content);
  @override
  List<Object?> get props => [content];
}

class StreamTokenReceived extends ChatEvent {
  final String token;
  const StreamTokenReceived(this.token);
  @override
  List<Object?> get props => [token];
}

class StreamCompleted extends ChatEvent {
  const StreamCompleted();
}

class StreamError extends ChatEvent {
  final String message;
  const StreamError(this.message);
  @override
  List<Object?> get props => [message];
}

class ClearChat extends ChatEvent {
  const ClearChat();
}
