import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  final String id;
  final String subjectId;
  final String front;
  final String back;
  final String difficulty; // easy, medium, hard
  final int repetitions;
  final double easeFactor;
  final int interval; // days
  final DateTime? nextReview;
  final DateTime createdAt;

  const Flashcard({
    required this.id,
    required this.subjectId,
    required this.front,
    required this.back,
    required this.difficulty,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 1,
    this.nextReview,
    required this.createdAt,
  });

  Flashcard copyWith({
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? nextReview,
  }) {
    return Flashcard(
      id: id,
      subjectId: subjectId,
      front: front,
      back: back,
      difficulty: difficulty,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, subjectId, front, back, difficulty,
        repetitions, easeFactor, interval, nextReview, createdAt,
      ];
}
