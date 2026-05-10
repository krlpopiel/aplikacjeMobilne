import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_app/core/constants/api_constants.dart';
import 'package:ai_study_app/core/constants/prompt_constants.dart';

void main() {
  group('PromptConstants', () {
    const testContext = 'Sample study material about Flutter widgets.';

    test('ragSystemPromptFull contains context and detailed instructions', () {
      final prompt = PromptConstants.ragSystemPromptFull(testContext);

      expect(prompt, contains(testContext));
      expect(prompt, contains('WYŁĄCZNIE'));
      expect(prompt, contains('<context>'));
    });

    test('ragSystemPromptCompact contains context and is shorter', () {
      final compact = PromptConstants.ragSystemPromptCompact(testContext);
      final full = PromptConstants.ragSystemPromptFull(testContext);

      expect(compact, contains(testContext));
      expect(compact.length, lessThan(full.length));
    });

    test('ragSystemPrompt selects compact for Ollama', () {
      final prompt =
          PromptConstants.ragSystemPrompt(testContext, AiProvider.ollama);
      expect(prompt, contains('tutorem'));
      expect(prompt, isNot(contains('WYŁĄCZNIE')));
    });

    test('ragSystemPrompt selects full for Anthropic', () {
      final prompt =
          PromptConstants.ragSystemPrompt(testContext, AiProvider.anthropic);
      expect(prompt, contains('WYŁĄCZNIE'));
      expect(prompt, contains('<context>'));
    });

    test('ragSystemPrompt selects full for OpenAI', () {
      final prompt =
          PromptConstants.ragSystemPrompt(testContext, AiProvider.openai);
      expect(prompt, contains('WYŁĄCZNIE'));
    });

    test('noMaterialsPrompt selects compact for Ollama', () {
      final prompt = PromptConstants.noMaterialsPrompt(AiProvider.ollama);
      expect(prompt.length, lessThan(200));
    });

    test('noMaterialsPrompt selects full for Anthropic', () {
      final prompt = PromptConstants.noMaterialsPrompt(AiProvider.anthropic);
      expect(prompt, contains('spersonalizowanych'));
    });
  });
}
