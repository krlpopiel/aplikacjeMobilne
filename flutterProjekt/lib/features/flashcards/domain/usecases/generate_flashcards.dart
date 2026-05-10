import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/sse_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/text_chunker.dart';
import '../../../materials/domain/repositories/materials_repository.dart';
import '../entities/flashcard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GenerateFlashcards {
  final MaterialsRepository materialsRepository;
  final SseClient sseClient;
  final FlutterSecureStorage secureStorage;
  final TextChunker textChunker;

  GenerateFlashcards({
    required this.materialsRepository,
    required this.sseClient,
    required this.secureStorage,
    required this.textChunker,
  });

  Future<Result<List<Flashcard>>> call({
    required String subjectId,
    int count = AppConstants.defaultFlashcardCount,
  }) async {
    try {
      final apiKey =
          await secureStorage.read(key: AppConstants.apiKeyKey);
      final providerStr =
          await secureStorage.read(key: AppConstants.apiProviderKey);

      if (apiKey == null || apiKey.isEmpty) {
        return const Error(
          ApiKeyFailure('Brak klucza API. Skonfiguruj go w ustawieniach.'),
        );
      }

      final provider = providerStr == 'openai'
          ? AiProvider.openai
          : AiProvider.anthropic;

      // Get material content
      final chunksResult =
          await materialsRepository.getAllChunksForSubject(subjectId);
      List<String> allChunks = [];
      chunksResult.fold(
        onSuccess: (chunks) => allChunks = chunks,
        onError: (f) {},
      );

      if (allChunks.isEmpty) {
        return const Error(
          ParsingFailure('Brak materiałów do wygenerowania fiszek.'),
        );
      }

      // Take representative chunks
      final materialContent = allChunks.take(20).join('\n\n');

      final systemPrompt = '''Na podstawie poniższych materiałów wygeneruj $count fiszek edukacyjnych.

Materiały:
<context>
$materialContent
</context>

Odpowiedz WYŁĄCZNIE w formacie JSON (bez markdown, bez komentarzy):
{
  "flashcards": [
    {
      "front": "Pytanie lub pojęcie",
      "back": "Odpowiedź lub definicja",
      "difficulty": "easy|medium|hard"
    }
  ]
}''';

      final response = await sseClient.getCompletion(
        systemPrompt: systemPrompt,
        messages: [
          {
            'role': 'user',
            'content': 'Wygeneruj $count fiszek edukacyjnych na podstawie podanych materiałów.',
          }
        ],
        provider: provider,
        apiKey: apiKey,
      );

      // Parse response
      final jsonStr = _extractJson(response);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final flashcardsList = data['flashcards'] as List<dynamic>;

      final uuid = const Uuid();
      final flashcards = flashcardsList.map((fc) {
        final map = fc as Map<String, dynamic>;
        return Flashcard(
          id: uuid.v4(),
          subjectId: subjectId,
          front: map['front'] as String,
          back: map['back'] as String,
          difficulty: map['difficulty'] as String? ?? 'medium',
          createdAt: DateTime.now(),
        );
      }).toList();

      return Success(flashcards);
    } catch (e) {
      return Error(ServerFailure('Błąd generowania fiszek: $e'));
    }
  }

  String _extractJson(String text) {
    // Try to find JSON in response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonMatch != null) return jsonMatch.group(0)!;
    return text;
  }
}
