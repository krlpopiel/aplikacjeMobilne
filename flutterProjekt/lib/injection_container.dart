import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'core/network/dio_client.dart';
import 'core/network/ollama_client.dart';
import 'core/network/sse_client.dart';
import 'core/services/image_ocr_service.dart';
import 'core/services/pdf_parser_service.dart';
import 'core/utils/text_chunker.dart';
import 'features/chat/data/datasources/chat_local_datasource.dart';
import 'features/chat/data/datasources/ollama_remote_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/chat_usecases.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/flashcards/domain/usecases/generate_flashcards.dart';
import 'features/flashcards/presentation/bloc/flashcards_bloc.dart';
import 'features/materials/data/datasources/materials_local_datasource.dart';
import 'features/materials/data/repositories/materials_repository_impl.dart';
import 'features/materials/domain/repositories/materials_repository.dart';
import 'features/materials/domain/usecases/material_usecases.dart';
import 'features/materials/presentation/bloc/materials_bloc.dart';
import 'features/quiz/domain/usecases/generate_quiz.dart';
import 'features/quiz/presentation/bloc/quiz_bloc.dart';
import 'features/settings/domain/usecases/get_ollama_models.dart';
import 'features/settings/domain/usecases/test_ollama_connection.dart';
import 'features/subjects/data/datasources/subjects_local_datasource.dart';
import 'features/subjects/data/repositories/subjects_repository_impl.dart';
import 'features/subjects/domain/repositories/subjects_repository.dart';
import 'features/subjects/domain/usecases/create_subject.dart';
import 'features/subjects/domain/usecases/delete_subject.dart';
import 'features/subjects/domain/usecases/get_subjects.dart';
import 'features/subjects/presentation/bloc/subjects_bloc.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Core
  getIt.registerLazySingleton(() => DioClient());
  getIt.registerLazySingleton(() => SseClient(getIt()));
  getIt.registerLazySingleton(() => OllamaClient());
  getIt.registerLazySingleton(() => TextChunker());
  getIt.registerLazySingleton(() => PdfParserService(getIt()));
  getIt.registerLazySingleton(() => ImageOcrService(getIt(), getIt()));
  getIt.registerLazySingleton(() => const FlutterSecureStorage());

  // Datasources
  getIt.registerFactory(() => SubjectsLocalDatasource());
  getIt.registerFactory(() => MaterialsLocalDatasource());
  getIt.registerFactory(() => ChatLocalDatasource());
  getIt.registerLazySingleton(() => OllamaRemoteDatasource());

  // Repositories
  getIt.registerLazySingleton<SubjectsRepository>(
    () => SubjectsRepositoryImpl(localDatasource: getIt()),
  );
  getIt.registerLazySingleton<MaterialsRepository>(
    () => MaterialsRepositoryImpl(localDatasource: getIt()),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      localDatasource: getIt(),
      sseClient: getIt(),
      ollamaClient: getIt(),
      secureStorage: getIt(),
    ),
  );

  // Use cases
  getIt.registerFactory(() => GetSubjects(getIt()));
  getIt.registerFactory(() => CreateSubject(getIt()));
  getIt.registerFactory(() => DeleteSubject(getIt()));
  getIt.registerFactory(() => UploadPdf(getIt()));
  getIt.registerFactory(() => UploadImage(getIt()));
  getIt.registerFactory(() => GetMaterialsForSubject(getIt()));
  getIt.registerFactory(() => DeleteMaterial(getIt()));
  getIt.registerFactory(() => SendMessageStream(getIt()));
  getIt.registerFactory(() => GetConversationHistory(getIt()));
  getIt.registerFactory(() => ClearConversation(getIt()));
  getIt.registerFactory(() => GenerateFlashcards(
        materialsRepository: getIt(),
        sseClient: getIt(),
        ollamaClient: getIt(),
        secureStorage: getIt(),
        textChunker: getIt(),
      ));
  getIt.registerFactory(() => GenerateQuiz(
        materialsRepository: getIt(),
        sseClient: getIt(),
        ollamaClient: getIt(),
        secureStorage: getIt(),
      ));
  // Ollama use cases
  getIt.registerFactory(() => GetOllamaModels(getIt()));
  getIt.registerFactory(() => TestOllamaConnection(getIt()));

  // BLoCs
  getIt.registerFactory(() => SubjectsBloc(
        getSubjects: getIt(),
        createSubject: getIt(),
        deleteSubject: getIt(),
      ));
  getIt.registerFactory(() => MaterialsBloc(
        getMaterials: getIt(),
        uploadPdf: getIt(),
        uploadImage: getIt(),
        deleteMaterial: getIt(),
        pdfParser: getIt(),
        imageOcr: getIt(),
        secureStorage: getIt(),
      ));
  getIt.registerFactory(() => ChatBloc(
        chatRepository: getIt(),
        materialsRepository: getIt(),
        textChunker: getIt(),
        secureStorage: getIt(),
      ));
  getIt.registerFactory(() => FlashcardsBloc(generateFlashcards: getIt()));
  getIt.registerFactory(() => QuizBloc(generateQuiz: getIt()));
}
