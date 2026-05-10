# Ollama Integration — Change Summary

## ✅ Status: 0 errors, 37/37 tests pass

---

## New Files Created (8)

| File | Purpose |
|---|---|
| [api_constants.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/core/constants/api_constants.dart) | `AiProvider.ollama` + Ollama endpoint constants |
| [prompt_constants.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/core/constants/prompt_constants.dart) | Full vs compact RAG prompts (cloud vs local) |
| [ollama_client.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/core/network/ollama_client.dart) | NDJSON streaming + non-streaming completion |
| [ollama_model.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/features/chat/data/models/ollama_model.dart) | `OllamaModel` entity + `OllamaModelX` extension |
| [ollama_remote_datasource.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/features/chat/data/datasources/ollama_remote_datasource.dart) | Fetch models + test connection |
| [get_ollama_models.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/features/settings/domain/usecases/get_ollama_models.dart) | Use case: list installed models |
| [test_ollama_connection.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/features/settings/domain/usecases/test_ollama_connection.dart) | Use case: validate server reachability |
| [ollama_model_test.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/test/features/chat/data/models/ollama_model_test.dart) | 10 unit tests for model entity |
| [prompt_constants_test.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/test/core/constants/prompt_constants_test.dart) | 7 unit tests for prompt selection |

## Modified Files (7)

| File | Changes |
|---|---|
| [api_constants.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/core/constants/api_constants.dart) | Added `ollama` to `AiProvider` enum, Ollama endpoints, `topKChunksOllama` |
| [app_constants.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/core/constants/app_constants.dart) | Added `ollamaBaseUrlKey` + `ollamaModelKey` |
| [failures.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/core/errors/failures.dart) | Added `OllamaNotReachableFailure`, `OllamaModelNotFoundFailure`, `OllamaStreamFailure` |
| [sse_client.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/core/network/sse_client.dart) | Added `AiProvider.ollama` case to switch (throws — use OllamaClient) |
| [chat_repository_impl.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/features/chat/data/repositories/chat_repository_impl.dart) | Provider switch dispatches to SSE or Ollama client |
| [chat_bloc.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/features/chat/presentation/bloc/chat_bloc.dart) | Reads provider, adjusts topK and prompt variant |
| [settings_page.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/features/settings/presentation/pages/settings_page.dart) | Full Ollama UI: URL, test button, status indicator, model list, privacy badge |
| [injection_container.dart](file:///c:/Users/adria/Desktop/kodowanie/III%20rok/mobilne/aplikacjeMobilne/flutterProjekt/lib/injection_container.dart) | Registered OllamaClient, datasource, use cases |

---

## Architecture Decisions

### NDJSON vs SSE — Separate clients
Ollama uses **NDJSON** (one JSON per line), not SSE (`data:` prefix). Created `OllamaClient` instead of modifying `SseClient` to maintain separation of concerns.

### Compact prompts for small models
Local 7B-13B models work better with shorter instructions. `PromptConstants` selects the appropriate variant based on provider.

### Reduced context for Ollama
`topKChunks` reduced from 5 → 3 for Ollama (4k-8k context window vs 100k+ for cloud).

### No API key for Ollama
API key field is hidden when Ollama is selected. Validation skipped in `ChatRepositoryImpl.getApiKey()`.

---

## Settings UI — Ollama Section

When "Ollama" is selected in the provider segmented button:
- **URL field** with test button (3s connect timeout)
- **Status indicator**: spinner → green check + model count → red error
- **Model radio list** with name, tag, and formatted size
- **Privacy notice**: "data doesn't leave your device"
- **Emulator hint**: use `10.0.2.2` instead of `localhost`
