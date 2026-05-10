import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/sse_client.dart';
import '../../../../core/utils/result.dart';
import '../../../materials/domain/repositories/materials_repository.dart';
import '../entities/quiz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GenerateQuiz {
  final MaterialsRepository materialsRepository;
  final SseClient sseClient;
  final FlutterSecureStorage secureStorage;

  GenerateQuiz({
    required this.materialsRepository,
    required this.sseClient,
    required this.secureStorage,
  });

  Future<Result<Quiz>> call({
    required String subjectId,
    int count = AppConstants.defaultQuizQuestionCount,
  }) async {
    try {
      final apiKey = await secureStorage.read(key: AppConstants.apiKeyKey);
      final providerStr = await secureStorage.read(key: AppConstants.apiProviderKey);

      if (apiKey == null || apiKey.isEmpty) {
        return const Error(ApiKeyFailure('Brak klucza API. Skonfiguruj go w ustawieniach.'));
      }

      final provider = providerStr == 'openai' ? AiProvider.openai : AiProvider.anthropic;

      final chunksResult = await materialsRepository.getAllChunksForSubject(subjectId);
      List<String> allChunks = [];
      chunksResult.fold(onSuccess: (c) => allChunks = c, onError: (_) {});

      if (allChunks.isEmpty) {
        return const Error(ParsingFailure('Brak materiałów do wygenerowania quizu.'));
      }

      final materialContent = allChunks.take(20).join('\n\n');

      final systemPrompt = '''Na podstawie materiałów wygeneruj quiz składający się z $count pytań.

Materiały:
<context>
$materialContent
</context>

Format JSON (bez markdown, bez komentarzy):
{
  "quiz": {
    "title": "Nazwa quizu",
    "questions": [
      {
        "id": "q1",
        "question": "Treść pytania",
        "type": "multiple_choice",
        "options": ["A", "B", "C", "D"],
        "correct_answer": "A",
        "explanation": "Dlaczego ta odpowiedź jest poprawna"
      }
    ]
  }
}''';

      final response = await sseClient.getCompletion(
        systemPrompt: systemPrompt,
        messages: [{'role': 'user', 'content': 'Wygeneruj quiz z $count pytań.'}],
        provider: provider,
        apiKey: apiKey,
      );

      final jsonStr = _extractJson(response);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final quizData = data['quiz'] as Map<String, dynamic>;
      final questions = (quizData['questions'] as List<dynamic>).map((q) {
        final m = q as Map<String, dynamic>;
        return QuizQuestion(
          id: m['id'] as String,
          question: m['question'] as String,
          type: m['type'] as String? ?? 'multiple_choice',
          options: (m['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
          correctAnswer: m['correct_answer'] as String,
          explanation: m['explanation'] as String? ?? '',
        );
      }).toList();

      return Success(Quiz(title: quizData['title'] as String? ?? 'Quiz', questions: questions));
    } catch (e) {
      return Error(ServerFailure('Błąd generowania quizu: $e'));
    }
  }

  String _extractJson(String text) {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    return match != null ? match.group(0)! : text;
  }
}
