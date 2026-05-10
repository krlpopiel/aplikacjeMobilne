import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/ollama_client.dart';
import '../../../../core/network/sse_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/text_chunker.dart';
import '../../../materials/domain/repositories/materials_repository.dart';
import '../entities/flashcard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GenerateFlashcards {
  final MaterialsRepository materialsRepository;
  final SseClient sseClient;
  final OllamaClient ollamaClient;
  final FlutterSecureStorage secureStorage;
  final TextChunker textChunker;

  GenerateFlashcards({
    required this.materialsRepository,
    required this.sseClient,
    required this.ollamaClient,
    required this.secureStorage,
    required this.textChunker,
  });

  Future<Result<List<Flashcard>>> call({
    required String subjectId,
    int count = AppConstants.defaultFlashcardCount,
  }) async {
    try {
      final providerStr =
          await secureStorage.read(key: AppConstants.apiProviderKey);
      final provider = switch (providerStr) {
        'openai' => AiProvider.openai,
        'ollama' => AiProvider.ollama,
        _ => AiProvider.anthropic,
      };

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

      final userMessage =
          'Wygeneruj $count fiszek edukacyjnych na podstawie podanych materiałów.';

      // Call appropriate provider
      final response = await _getCompletion(
        provider: provider,
        systemPrompt: systemPrompt,
        userMessage: userMessage,
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

  Future<String> _getCompletion({
    required AiProvider provider,
    required String systemPrompt,
    required String userMessage,
  }) async {
    switch (provider) {
      case AiProvider.anthropic:
      case AiProvider.openai:
        final apiKey =
            await secureStorage.read(key: AppConstants.apiKeyKey);
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception(
              'Brak klucza API. Skonfiguruj go w ustawieniach.');
        }
        return sseClient.getCompletion(
          systemPrompt: systemPrompt,
          messages: [
            {'role': 'user', 'content': userMessage}
          ],
          provider: provider,
          apiKey: apiKey,
        );

      case AiProvider.ollama:
        final baseUrl = await secureStorage.read(
                key: AppConstants.ollamaBaseUrlKey) ??
            ApiConstants.ollamaDefaultBaseUrl;
        final model = await secureStorage.read(
                key: AppConstants.ollamaModelKey) ??
            '';
        if (model.isEmpty) {
          throw Exception(
              'Brak wybranego modelu Ollama. Skonfiguruj go w ustawieniach.');
        }
        return ollamaClient.getCompletion(
          baseUrl: baseUrl,
          model: model,
          systemPrompt: systemPrompt,
          messages: [
            {'role': 'user', 'content': userMessage}
          ],
        );
    }
  }

  String _extractJson(String text) {
    // Try to find JSON in response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonMatch != null) return jsonMatch.group(0)!;
    return text;
  }
}
