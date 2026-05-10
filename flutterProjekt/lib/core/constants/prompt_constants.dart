import '../constants/api_constants.dart';

class PromptConstants {
  PromptConstants._();

  /// Full RAG system prompt for powerful cloud models (Claude, GPT).
  static String ragSystemPromptFull(String context) => '''
Jesteś asystentem nauki. Masz dostęp do następujących materiałów studenta:

<context>
$context
</context>

Odpowiadaj WYŁĄCZNIE na podstawie powyższych materiałów. 
Jeśli informacja nie znajduje się w materiałach, powiedz o tym wprost.
Cytuj konkretne fragmenty gdy to możliwe.
Odpowiadaj w języku, w którym zadano pytanie.''';

  /// Compact RAG system prompt optimized for smaller local models (Ollama).
  static String ragSystemPromptCompact(String context) => '''
Jesteś pomocnym tutorem. Użyj poniższego kontekstu do odpowiedzi na pytanie studenta.
Kontekst: $context
Zasady: odpowiadaj tylko na podstawie kontekstu, bądź zwięzły, mów po polsku jeśli pytanie po polsku.''';

  /// Select the appropriate prompt variant based on the AI provider.
  static String ragSystemPrompt(String context, AiProvider provider) =>
      provider == AiProvider.ollama
          ? ragSystemPromptCompact(context)
          : ragSystemPromptFull(context);

  /// No-materials prompt (full variant).
  static String noMaterialsPromptFull() => '''
Jesteś asystentem nauki. Student nie wgrał jeszcze żadnych materiałów do tego przedmiotu.
Odpowiadaj na pytania ogólne, ale zasugeruj wgranie materiałów dla lepszych, spersonalizowanych odpowiedzi.
Odpowiadaj w języku, w którym zadano pytanie.''';

  /// No-materials prompt (compact for Ollama).
  static String noMaterialsPromptCompact() => '''
Jesteś pomocnym tutorem. Student nie wgrał materiałów. Odpowiadaj ogólnie i zasugeruj wgranie materiałów.''';

  /// Select the appropriate no-materials prompt based on the AI provider.
  static String noMaterialsPrompt(AiProvider provider) =>
      provider == AiProvider.ollama
          ? noMaterialsPromptCompact()
          : noMaterialsPromptFull();
}
