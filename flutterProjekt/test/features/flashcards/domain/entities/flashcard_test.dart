import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_app/features/flashcards/domain/entities/flashcard.dart';

void main() {
  group('Flashcard Entity', () {
    test('default SM-2 values', () {
      final card = Flashcard(
        id: '1', subjectId: 's1',
        front: 'What is Dart?', back: 'A programming language',
        difficulty: 'medium', createdAt: DateTime(2024, 1, 1),
      );
      expect(card.repetitions, 0);
      expect(card.easeFactor, 2.5);
      expect(card.interval, 1);
      expect(card.nextReview, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final card = Flashcard(
        id: '1', subjectId: 's1',
        front: 'Q', back: 'A', difficulty: 'easy',
        createdAt: DateTime(2024, 1, 1),
      );
      final updated = card.copyWith(repetitions: 3, easeFactor: 2.6);
      expect(updated.repetitions, 3);
      expect(updated.easeFactor, 2.6);
      expect(updated.front, 'Q');
      expect(updated.back, 'A');
    });

    test('supports equality', () {
      final card1 = Flashcard(
        id: '1', subjectId: 's1',
        front: 'Q', back: 'A', difficulty: 'easy',
        createdAt: DateTime(2024, 1, 1),
      );
      final card2 = Flashcard(
        id: '1', subjectId: 's1',
        front: 'Q', back: 'A', difficulty: 'easy',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(card1, equals(card2));
    });
  });
}
