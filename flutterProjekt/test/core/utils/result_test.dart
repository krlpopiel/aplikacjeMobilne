import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_app/core/utils/result.dart';
import 'package:ai_study_app/core/errors/failures.dart';

void main() {
  group('Result', () {
    test('Success holds data', () {
      const result = Success<int>(42);
      expect(result.isSuccess, true);
      expect(result.isError, false);
      expect(result.value, 42);
    });

    test('Error holds failure', () {
      const result = Error<int>(ServerFailure('test error'));
      expect(result.isSuccess, false);
      expect(result.isError, true);
      expect(result.failure.message, 'test error');
    });

    test('fold calls onSuccess for Success', () {
      const result = Success<String>('hello');
      final output = result.fold(
        onSuccess: (data) => 'success: $data',
        onError: (failure) => 'error: ${failure.message}',
      );
      expect(output, 'success: hello');
    });

    test('fold calls onError for Error', () {
      const result = Error<String>(CacheFailure('cache miss'));
      final output = result.fold(
        onSuccess: (data) => 'success: $data',
        onError: (failure) => 'error: ${failure.message}',
      );
      expect(output, 'error: cache miss');
    });

    test('Success with null data', () {
      const result = Success<void>(null);
      expect(result.isSuccess, true);
    });
  });
}
