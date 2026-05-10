import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';

class ChatState extends Equatable {
  final List<Message> messages;
  final String? streamingMessage;
  final bool isStreaming;
  final String? conversationId;
  final String? subjectId;
  final bool isLoading;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.streamingMessage,
    this.isStreaming = false,
    this.conversationId,
    this.subjectId,
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<Message>? messages,
    String? streamingMessage,
    bool? isStreaming,
    String? conversationId,
    String? subjectId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      streamingMessage: streamingMessage ?? this.streamingMessage,
      isStreaming: isStreaming ?? this.isStreaming,
      conversationId: conversationId ?? this.conversationId,
      subjectId: subjectId ?? this.subjectId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  ChatState clearStreamingMessage() {
    return ChatState(
      messages: messages,
      streamingMessage: null,
      isStreaming: false,
      conversationId: conversationId,
      subjectId: subjectId,
      isLoading: false,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        streamingMessage,
        isStreaming,
        conversationId,
        subjectId,
        isLoading,
        errorMessage,
      ];
}
