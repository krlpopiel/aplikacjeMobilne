import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_app/features/subjects/domain/entities/subject.dart';

void main() {
  group('Subject Entity', () {
    test('supports equality', () {
      final subject1 = Subject(
        id: '1', name: 'Math', colorValue: 0xFF0000,
        createdAt: DateTime(2024, 1, 1),
      );
      final subject2 = Subject(
        id: '1', name: 'Math', colorValue: 0xFF0000,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(subject1, equals(subject2));
    });

    test('copyWith creates new instance with updated fields', () {
      final subject = Subject(
        id: '1', name: 'Math', colorValue: 0xFF0000,
        createdAt: DateTime(2024, 1, 1),
      );
      final updated = subject.copyWith(name: 'Physics');
      expect(updated.name, 'Physics');
      expect(updated.id, '1');
      expect(updated.colorValue, 0xFF0000);
    });

    test('default material and conversation counts are 0', () {
      final subject = Subject(
        id: '1', name: 'Math', colorValue: 0xFF0000,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(subject.materialCount, 0);
      expect(subject.conversationCount, 0);
    });
  });
}
