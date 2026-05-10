import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/usecases/generate_flashcards.dart';

// Events
sealed class FlashcardsEvent extends Equatable {
  const FlashcardsEvent();
  @override
  List<Object?> get props => [];
}

class LoadFlashcards extends FlashcardsEvent {
  final String subjectId;
  const LoadFlashcards(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class GenerateFlashcardsEvent extends FlashcardsEvent {
  final String subjectId;
  final int count;
  const GenerateFlashcardsEvent({required this.subjectId, this.count = 15});
  @override
  List<Object?> get props => [subjectId, count];
}

class FlipCard extends FlashcardsEvent {
  const FlipCard();
}

class NextCard extends FlashcardsEvent {
  final int quality; // 0-5 for SM-2
  const NextCard(this.quality);
  @override
  List<Object?> get props => [quality];
}

class PreviousCard extends FlashcardsEvent {
  const PreviousCard();
}

// State
enum FlashcardsStatus { initial, loading, generating, loaded, studying, error }

class FlashcardsState extends Equatable {
  final FlashcardsStatus status;
  final List<Flashcard> flashcards;
  final int currentIndex;
  final bool isFlipped;
  final String? errorMessage;
  final String subjectId;

  const FlashcardsState({
    this.status = FlashcardsStatus.initial,
    this.flashcards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.errorMessage,
    this.subjectId = '',
  });

  FlashcardsState copyWith({
    FlashcardsStatus? status,
    List<Flashcard>? flashcards,
    int? currentIndex,
    bool? isFlipped,
    String? errorMessage,
    String? subjectId,
  }) {
    return FlashcardsState(
      status: status ?? this.status,
      flashcards: flashcards ?? this.flashcards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      errorMessage: errorMessage,
      subjectId: subjectId ?? this.subjectId,
    );
  }

  @override
  List<Object?> get props =>
      [status, flashcards, currentIndex, isFlipped, errorMessage, subjectId];
}

// BLoC
class FlashcardsBloc extends Bloc<FlashcardsEvent, FlashcardsState> {
  final GenerateFlashcards _generateFlashcards;

  FlashcardsBloc({required GenerateFlashcards generateFlashcards})
      : _generateFlashcards = generateFlashcards,
        super(const FlashcardsState()) {
    on<LoadFlashcards>(_onLoad);
    on<GenerateFlashcardsEvent>(_onGenerate);
    on<FlipCard>(_onFlip);
    on<NextCard>(_onNext);
    on<PreviousCard>(_onPrevious);
  }

  Future<void> _onLoad(
      LoadFlashcards event, Emitter<FlashcardsState> emit) async {
    emit(state.copyWith(
      status: FlashcardsStatus.loading,
      subjectId: event.subjectId,
    ));

    try {
      final box = Hive.box(AppConstants.flashcardsBox);
      final flashcards = <Flashcard>[];

      for (final key in box.keys) {
        final data = Map<String, dynamic>.from(box.get(key) as Map);
        if (data['subjectId'] == event.subjectId) {
          flashcards.add(Flashcard(
            id: data['id'] as String,
            subjectId: data['subjectId'] as String,
            front: data['front'] as String,
            back: data['back'] as String,
            difficulty: data['difficulty'] as String? ?? 'medium',
            repetitions: data['repetitions'] as int? ?? 0,
            easeFactor: (data['easeFactor'] as num?)?.toDouble() ?? 2.5,
            interval: data['interval'] as int? ?? 1,
            nextReview: data['nextReview'] != null
                ? DateTime.parse(data['nextReview'] as String)
                : null,
            createdAt: DateTime.parse(data['createdAt'] as String),
          ));
        }
      }

      emit(state.copyWith(
        status: FlashcardsStatus.loaded,
        flashcards: flashcards,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FlashcardsStatus.error,
        errorMessage: 'Błąd ładowania fiszek: $e',
      ));
    }
  }

  Future<void> _onGenerate(
      GenerateFlashcardsEvent event, Emitter<FlashcardsState> emit) async {
    emit(state.copyWith(status: FlashcardsStatus.generating));

    final result = await _generateFlashcards(
      subjectId: event.subjectId,
      count: event.count,
    );

    result.fold(
      onSuccess: (flashcards) {
        final box = Hive.box(AppConstants.flashcardsBox);
        for (final fc in flashcards) {
          box.put(fc.id, {
            'id': fc.id,
            'subjectId': fc.subjectId,
            'front': fc.front,
            'back': fc.back,
            'difficulty': fc.difficulty,
            'repetitions': fc.repetitions,
            'easeFactor': fc.easeFactor,
            'interval': fc.interval,
            'nextReview': fc.nextReview?.toIso8601String(),
            'createdAt': fc.createdAt.toIso8601String(),
          });
        }

        emit(state.copyWith(
          status: FlashcardsStatus.loaded,
          flashcards: [...state.flashcards, ...flashcards],
        ));
      },
      onError: (failure) {
        emit(state.copyWith(
          status: FlashcardsStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  void _onFlip(FlipCard event, Emitter<FlashcardsState> emit) {
    emit(state.copyWith(isFlipped: !state.isFlipped));
  }

  Future<void> _onNext(NextCard event, Emitter<FlashcardsState> emit) async {
    if (state.flashcards.isEmpty) return;

    final card = state.flashcards[state.currentIndex];
    final quality = event.quality;

    double ef = card.easeFactor;
    int reps = card.repetitions;
    int interval = card.interval;

    if (quality >= 3) {
      if (reps == 0) {
        interval = 1;
      } else if (reps == 1) {
        interval = 6;
      } else {
        interval = (interval * ef).round();
      }
      reps++;
      ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    } else {
      reps = 0;
      interval = 1;
    }
    if (ef < 1.3) ef = 1.3;

    final updatedCard = card.copyWith(
      repetitions: reps,
      easeFactor: ef,
      interval: interval,
      nextReview: DateTime.now().add(Duration(days: interval)),
    );

    final box = Hive.box(AppConstants.flashcardsBox);
    await box.put(updatedCard.id, {
      'id': updatedCard.id,
      'subjectId': updatedCard.subjectId,
      'front': updatedCard.front,
      'back': updatedCard.back,
      'difficulty': updatedCard.difficulty,
      'repetitions': updatedCard.repetitions,
      'easeFactor': updatedCard.easeFactor,
      'interval': updatedCard.interval,
      'nextReview': updatedCard.nextReview?.toIso8601String(),
      'createdAt': updatedCard.createdAt.toIso8601String(),
    });

    final updatedList = List<Flashcard>.from(state.flashcards);
    updatedList[state.currentIndex] = updatedCard;

    final nextIndex = (state.currentIndex + 1) % updatedList.length;
    emit(state.copyWith(
      flashcards: updatedList,
      currentIndex: nextIndex,
      isFlipped: false,
    ));
  }

  void _onPrevious(PreviousCard event, Emitter<FlashcardsState> emit) {
    if (state.flashcards.isEmpty) return;
    final prevIndex = state.currentIndex > 0
        ? state.currentIndex - 1
        : state.flashcards.length - 1;
    emit(state.copyWith(currentIndex: prevIndex, isFlipped: false));
  }
}
