
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/flashcards/presentation/bloc/flashcards_bloc.dart';
import 'features/flashcards/presentation/pages/flashcards_page.dart';
import 'features/materials/presentation/bloc/materials_bloc.dart';
import 'features/materials/presentation/bloc/materials_event.dart';
import 'features/materials/presentation/pages/materials_page.dart';
import 'features/quiz/presentation/bloc/quiz_bloc.dart';
import 'features/quiz/presentation/pages/quiz_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/subjects/presentation/bloc/subjects_bloc.dart';
import 'features/subjects/presentation/bloc/subjects_event.dart';
import 'features/subjects/presentation/pages/subject_detail_page.dart';
import 'features/subjects/presentation/pages/subjects_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => GetIt.I<SubjectsBloc>()..add(const LoadSubjects()),
        child: const SubjectsPage(),
      ),
    ),
    GoRoute(
      path: '/subjects/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return SubjectDetailPage(subjectId: id);
      },
    ),
    GoRoute(
      path: '/subjects/:id/materials',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => GetIt.I<MaterialsBloc>()..add(LoadMaterials(id)),
          child: MaterialsPage(subjectId: id),
        );
      },
    ),
    GoRoute(
      path: '/subjects/:id/chat',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => GetIt.I<ChatBloc>(),
          child: ChatPage(subjectId: id),
        );
      },
    ),
    GoRoute(
      path: '/subjects/:id/chat/:convId',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final convId = state.pathParameters['convId']!;
        return BlocProvider(
          create: (_) => GetIt.I<ChatBloc>(),
          child: ChatPage(subjectId: id, conversationId: convId),
        );
      },
    ),
    GoRoute(
      path: '/subjects/:id/flashcards',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => GetIt.I<FlashcardsBloc>(),
          child: FlashcardsPage(subjectId: id),
        );
      },
    ),
    GoRoute(
      path: '/subjects/:id/quiz',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => GetIt.I<QuizBloc>(),
          child: QuizPage(subjectId: id),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
