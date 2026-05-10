import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_app/features/chat/data/models/ollama_model.dart';

void main() {
  group('OllamaModel', () {
    test('fromJson creates instance correctly', () {
      final json = {
        'name': 'llama3.2:latest',
        'size': 2019393189,
        'modified_at': '2024-01-15T10:30:00Z',
      };

      final model = OllamaModel.fromJson(json);

      expect(model.name, 'llama3.2:latest');
      expect(model.size, 2019393189);
      expect(model.modifiedAt, '2024-01-15T10:30:00Z');
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};
      final model = OllamaModel.fromJson(json);

      expect(model.name, '');
      expect(model.size, 0);
      expect(model.modifiedAt, '');
    });

    test('supports equality', () {
      const model1 = OllamaModel(
          name: 'llama3.2:latest', size: 100, modifiedAt: '2024');
      const model2 = OllamaModel(
          name: 'llama3.2:latest', size: 100, modifiedAt: '2024');
      expect(model1, equals(model2));
    });
  });

  group('OllamaModelX', () {
    test('displayName strips tag', () {
      const model = OllamaModel(
          name: 'llama3.2:latest', size: 0, modifiedAt: '');
      expect(model.displayName, 'llama3.2');
    });

    test('displayName handles no tag', () {
      const model =
          OllamaModel(name: 'mistral', size: 0, modifiedAt: '');
      expect(model.displayName, 'mistral');
    });

    test('tag returns correct portion', () {
      const model = OllamaModel(
          name: 'phi4:q4_k_m', size: 0, modifiedAt: '');
      expect(model.tag, 'q4_k_m');
    });

    test('tag returns latest when no tag present', () {
      const model =
          OllamaModel(name: 'gemma3', size: 0, modifiedAt: '');
      expect(model.tag, 'latest');
    });

    test('sizeFormatted shows GB for large models', () {
      const model = OllamaModel(
          name: 'llama3.2:latest', size: 4100000000, modifiedAt: '');
      expect(model.sizeFormatted, '4.1 GB');
    });

    test('sizeFormatted shows MB for small models', () {
      const model = OllamaModel(
          name: 'phi:latest', size: 750000000, modifiedAt: '');
      expect(model.sizeFormatted, '750 MB');
    });

    test('isLargeModel detects 70B models', () {
      const large = OllamaModel(
          name: 'llama3.1:70b', size: 0, modifiedAt: '');
      const small = OllamaModel(
          name: 'llama3.2:latest', size: 0, modifiedAt: '');

      expect(large.isLargeModel, true);
      expect(small.isLargeModel, false);
    });
  });
}
