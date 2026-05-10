import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/usecases/generate_quiz.dart';

// Events
sealed class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

class GenerateQuizEvent extends QuizEvent {
  final String subjectId;
  final int count;
  const GenerateQuizEvent({required this.subjectId, this.count = 10});
  @override
  List<Object?> get props => [subjectId, count];
}

class AnswerQuestion extends QuizEvent {
  final String answer;
  const AnswerQuestion(this.answer);
  @override
  List<Object?> get props => [answer];
}

class NextQuestion extends QuizEvent {
  const NextQuestion();
}

// State
enum QuizStatus { initial, generating, inProgress, answered, completed, error }

class QuizState extends Equatable {
  final QuizStatus status;
  final Quiz? quiz;
  final int currentIndex;
  final String? selectedAnswer;
  final bool? isCorrect;
  final int correctCount;
  final int totalAnswered;
  final String? errorMessage;
  final DateTime? startTime;

  const QuizState({
    this.status = QuizStatus.initial,
    this.quiz,
    this.currentIndex = 0,
    this.selectedAnswer,
    this.isCorrect,
    this.correctCount = 0,
    this.totalAnswered = 0,
    this.errorMessage,
    this.startTime,
  });

  QuizState copyWith({
    QuizStatus? status, Quiz? quiz, int? currentIndex,
    String? selectedAnswer, bool? isCorrect,
    int? correctCount, int? totalAnswered,
    String? errorMessage, DateTime? startTime,
  }) {
    return QuizState(
      status: status ?? this.status,
      quiz: quiz ?? this.quiz,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      correctCount: correctCount ?? this.correctCount,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      errorMessage: errorMessage,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  List<Object?> get props => [status, quiz, currentIndex, selectedAnswer,
      isCorrect, correctCount, totalAnswered, errorMessage, startTime];
}

// BLoC
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GenerateQuiz _generateQuiz;

  QuizBloc({required GenerateQuiz generateQuiz})
      : _generateQuiz = generateQuiz,
        super(const QuizState()) {
    on<GenerateQuizEvent>(_onGenerate);
    on<AnswerQuestion>(_onAnswer);
    on<NextQuestion>(_onNext);
  }

  Future<void> _onGenerate(GenerateQuizEvent event, Emitter<QuizState> emit) async {
    emit(state.copyWith(status: QuizStatus.generating));
    final result = await _generateQuiz(subjectId: event.subjectId, count: event.count);
    result.fold(
      onSuccess: (quiz) => emit(QuizState(
        status: QuizStatus.inProgress,
        quiz: quiz,
        startTime: DateTime.now(),
      )),
      onError: (f) => emit(state.copyWith(
        status: QuizStatus.error, errorMessage: f.message,
      )),
    );
  }

  void _onAnswer(AnswerQuestion event, Emitter<QuizState> emit) {
    if (state.quiz == null) return;
    final question = state.quiz!.questions[state.currentIndex];
    final correct = event.answer.toLowerCase() == question.correctAnswer.toLowerCase();
    emit(state.copyWith(
      status: QuizStatus.answered,
      selectedAnswer: event.answer,
      isCorrect: correct,
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
      totalAnswered: state.totalAnswered + 1,
    ));
  }

  void _onNext(NextQuestion event, Emitter<QuizState> emit) {
    if (state.quiz == null) return;
    if (state.currentIndex + 1 >= state.quiz!.questions.length) {
      emit(state.copyWith(status: QuizStatus.completed));
    } else {
      emit(state.copyWith(
        status: QuizStatus.inProgress,
        currentIndex: state.currentIndex + 1,
      ));
    }
  }
}
