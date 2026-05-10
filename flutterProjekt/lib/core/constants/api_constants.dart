class ApiConstants {
  ApiConstants._();

  // Anthropic
  static const anthropicBaseUrl = 'https://api.anthropic.com/v1';
  static const anthropicModel = 'claude-sonnet-4-20250514';
  static const anthropicVersion = '2023-06-01';

  // OpenAI
  static const openAiBaseUrl = 'https://api.openai.com/v1';
  static const openAiModel = 'gpt-4o';

  // Ollama
  static const ollamaDefaultBaseUrl = 'http://localhost:11434';
  static const ollamaModelsEndpoint = '/api/tags';
  static const ollamaChatEndpoint = '/api/chat';
  static const ollamaGenerateEndpoint = '/api/generate';

  // Limits
  static const maxContextTokens = 100000;
  static const maxResponseTokens = 4096;
  static const chunkSize = 500;
  static const chunkOverlap = 50;
  static const topKChunks = 5;
  static const topKChunksOllama = 3; // smaller context for local models
}

enum AiProvider { anthropic, openai, ollama }
