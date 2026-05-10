# AI Study App — Flutter Project Summary

## ✅ Project Status: Complete & Compiling

- **0 errors** in `flutter analyze`
- **20/20 tests passing**
- All files created following Clean Architecture pattern

---

## Architecture Overview

```
lib/
├── core/                          # Shared infrastructure
│   ├── constants/                 # API & app constants
│   ├── errors/                    # Sealed Failure & Exception classes
│   ├── network/                   # DioClient + SSE streaming client
│   ├── services/                  # PDF parser + Image OCR (AI Vision)
│   └── utils/                     # Result<T> type + TextChunker (TF-IDF)
│
├── features/
│   ├── subjects/                  # Subject management (CRUD)
│   │   ├── data/                  # Hive datasource + repository impl
│   │   ├── domain/                # Entity + repository interface + usecases
│   │   └── presentation/         # BLoC + SubjectsPage + SubjectDetailPage
│   │
│   ├── materials/                 # PDF/image upload + text chunking
│   │   ├── data/                  # Hive storage, JSON chunk serialization
│   │   ├── domain/                # StudyMaterial entity + usecases
│   │   └── presentation/         # BLoC + MaterialsPage
│   │
│   ├── chat/                      # RAG chat with AI streaming
│   │   ├── data/                  # Local conversation/message storage
│   │   ├── domain/                # Message/Conversation entities
│   │   └── presentation/         # ChatBloc (streaming) + ChatPage
│   │
│   ├── flashcards/               # AI-generated flashcards
│   │   ├── domain/                # Flashcard entity + GenerateFlashcards usecase
│   │   └── presentation/         # FlashcardsBloc (SM-2) + FlashcardsPage
│   │
│   ├── quiz/                     # AI-generated quizzes
│   │   ├── domain/                # Quiz/QuizQuestion + GenerateQuiz usecase
│   │   └── presentation/         # QuizBloc + QuizPage
│   │
│   └── settings/                 # API key configuration
│       └── presentation/         # SettingsPage
│
├── injection_container.dart       # get_it DI setup
├── app_router.dart               # go_router navigation
└── main.dart                     # App entry point + theme
```

---

## Key Features Implemented

| Feature | Details |
|---|---|
| **PDF Parsing** | Syncfusion → text → chunks (500 words, 50 overlap) |
| **Image OCR** | AI Vision (Claude/GPT-4o) → text → chunks |
| **RAG Chat** | TF-IDF relevance → top-5 chunks → system prompt context |
| **Streaming** | SSE client for both Anthropic & OpenAI (token-by-token) |
| **Flashcards** | AI-generated, SM-2 spaced repetition, 3D flip animation |
| **Quiz** | AI-generated MCQ, feedback per question, scoring |
| **Settings** | flutter_secure_storage for API keys |
| **Theme** | Material 3, dark/light, Google Fonts (Inter) |

---

## How to Use

1. **Configure API key**: Go to Settings → enter your Anthropic or OpenAI key
2. **Create a subject**: Tap "+" on the main screen
3. **Upload materials**: Navigate to Materials → upload PDFs or capture notes
4. **Chat with AI**: Ask questions about your materials
5. **Generate flashcards**: AI creates flashcards from your content
6. **Take quizzes**: Test your knowledge with AI-generated questions

---

## Tests

```
✅ 5 Result type tests
✅ 8 TextChunker tests (chunking + TF-IDF search)
✅ 3 Subject entity tests
✅ 3 Flashcard entity tests  
✅ 1 placeholder widget test
= 20 total tests passing
```
