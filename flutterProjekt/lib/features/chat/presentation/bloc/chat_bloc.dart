import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/prompt_constants.dart';
import '../../../../core/utils/text_chunker.dart';
import '../../../materials/domain/repositories/materials_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final MaterialsRepository _materialsRepository;
  final TextChunker _textChunker;
  final FlutterSecureStorage _secureStorage;

  StreamSubscription<String>? _streamSubscription;

  ChatBloc({
    required ChatRepository chatRepository,
    required MaterialsRepository materialsRepository,
    required TextChunker textChunker,
    required FlutterSecureStorage secureStorage,
  })  : _chatRepository = chatRepository,
        _materialsRepository = materialsRepository,
        _textChunker = textChunker,
        _secureStorage = secureStorage,
        super(const ChatState()) {
    on<LoadConversation>(_onLoadConversation);
    on<SendMessage>(_onSendMessage);
    on<StreamTokenReceived>(_onStreamToken);
    on<StreamCompleted>(_onStreamCompleted);
    on<StreamError>(_onStreamError);
    on<ClearChat>(_onClearChat);
  }

  Future<AiProvider> _getCurrentProvider() async {
    final providerStr =
        await _secureStorage.read(key: AppConstants.apiProviderKey);
    return switch (providerStr) {
      'openai' => AiProvider.openai,
      'ollama' => AiProvider.ollama,
      _ => AiProvider.anthropic,
    };
  }

  Future<void> _onLoadConversation(
    LoadConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      subjectId: event.subjectId,
    ));

    if (event.conversationId != null) {
      final result =
          await _chatRepository.getConversation(event.conversationId!);
      result.fold(
        onSuccess: (conversation) {
          emit(state.copyWith(
            isLoading: false,
            conversationId: conversation.id,
            messages: conversation.messages,
          ));
        },
        onError: (failure) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
        },
      );
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final subjectId = state.subjectId;
    if (subjectId == null) return;

    // Create conversation if needed
    String? conversationId = state.conversationId;
    if (conversationId == null) {
      final title = event.content.length > 50
          ? '${event.content.substring(0, 50)}...'
          : event.content;
      final result = await _chatRepository.createConversation(
        subjectId: subjectId,
        title: title,
      );
      result.fold(
        onSuccess: (conv) => conversationId = conv.id,
        onError: (f) {
          emit(state.copyWith(errorMessage: f.message));
          return;
        },
      );
    }

    if (conversationId == null) return;

    // Save user message
    final userMsgResult = await _chatRepository.saveMessage(
      conversationId: conversationId!,
      role: 'user',
      content: event.content,
    );

    final updatedMessages = [...state.messages];
    userMsgResult.fold(
      onSuccess: (msg) => updatedMessages.add(msg),
      onError: (_) {},
    );

    emit(state.copyWith(
      conversationId: conversationId,
      messages: updatedMessages,
      isStreaming: true,
      streamingMessage: '',
    ));

    // Determine provider for prompt optimization
    final provider = await _getCurrentProvider();

    // Adjust topK based on provider (local models have smaller context windows)
    final topK = provider == AiProvider.ollama
        ? ApiConstants.topKChunksOllama
        : ApiConstants.topKChunks;

    // Get relevant chunks for RAG
    final chunksResult =
        await _materialsRepository.getAllChunksForSubject(subjectId);
    String contextStr = '';
    chunksResult.fold(
      onSuccess: (allChunks) {
        if (allChunks.isNotEmpty) {
          final relevant = _textChunker.findRelevantChunks(
              event.content, allChunks,
              topK: topK);
          contextStr = relevant.join('\n\n---\n\n');
        }
      },
      onError: (_) {},
    );

    // Use provider-appropriate prompt
    final systemPrompt = contextStr.isNotEmpty
        ? PromptConstants.ragSystemPrompt(contextStr, provider)
        : PromptConstants.noMaterialsPrompt(provider);

    // Build messages list for API
    final apiMessages = updatedMessages.map((m) {
      return {'role': m.role, 'content': m.content};
    }).toList();

    // Start streaming
    try {
      final stream = _chatRepository.streamResponse(
        systemPrompt: systemPrompt,
        messages: apiMessages,
      );

      _streamSubscription?.cancel();
      _streamSubscription = stream.listen(
        (token) => add(StreamTokenReceived(token)),
        onDone: () => add(const StreamCompleted()),
        onError: (error) => add(StreamError(error.toString())),
      );
    } catch (e) {
      emit(state.copyWith(
        isStreaming: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onStreamToken(
    StreamTokenReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state.streamingMessage ?? '';
    emit(state.copyWith(
      streamingMessage: current + event.token,
    ));
  }

  Future<void> _onStreamCompleted(
    StreamCompleted event,
    Emitter<ChatState> emit,
  ) async {
    final fullResponse = state.streamingMessage ?? '';
    if (fullResponse.isNotEmpty && state.conversationId != null) {
      final result = await _chatRepository.saveMessage(
        conversationId: state.conversationId!,
        role: 'assistant',
        content: fullResponse,
      );

      final updatedMessages = [...state.messages];
      result.fold(
        onSuccess: (msg) => updatedMessages.add(msg),
        onError: (_) {},
      );

      emit(state.clearStreamingMessage().copyWith(
            messages: updatedMessages,
          ));
    } else {
      emit(state.clearStreamingMessage());
    }
  }

  void _onStreamError(
    StreamError event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      isStreaming: false,
      errorMessage: event.message,
    ));
  }

  Future<void> _onClearChat(
    ClearChat event,
    Emitter<ChatState> emit,
  ) async {
    if (state.conversationId != null) {
      await _chatRepository.deleteConversation(state.conversationId!);
    }
    emit(const ChatState());
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
