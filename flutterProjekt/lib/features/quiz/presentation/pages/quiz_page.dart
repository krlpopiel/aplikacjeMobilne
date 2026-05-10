import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/quiz_bloc.dart';

class QuizPage extends StatelessWidget {
  final String subjectId;
  const QuizPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz'), centerTitle: true),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          return switch (state.status) {
            QuizStatus.initial => _InitialView(subjectId: subjectId),
            QuizStatus.generating => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generowanie quizu z AI...'),
                  ],
                ),
              ),
            QuizStatus.inProgress || QuizStatus.answered =>
              _QuestionView(state: state),
            QuizStatus.completed => _ResultsView(state: state, subjectId: subjectId),
            QuizStatus.error => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(state.errorMessage ?? 'Błąd'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<QuizBloc>()
                          .add(GenerateQuizEvent(subjectId: subjectId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  final String subjectId;
  const _InitialView({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Sprawdź swoją wiedzę',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Wygeneruj quiz z materiałów'),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => context.read<QuizBloc>()
                .add(GenerateQuizEvent(subjectId: subjectId)),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generuj quiz (10 pytań)'),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          ),
        ],
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuizState state;
  const _QuestionView({required this.state});

  @override
  Widget build(BuildContext context) {
    final quiz = state.quiz!;
    final question = quiz.questions[state.currentIndex];
    final progress = (state.currentIndex + 1) / quiz.questions.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pytanie ${state.currentIndex + 1}/${quiz.questions.length}',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('${state.correctCount} poprawnych',
                  style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, minHeight: 6,
              borderRadius: BorderRadius.circular(3)),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(question.question,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
          const SizedBox(height: 16),
          if (question.options != null)
            ...question.options!.map((option) {
              final isSelected = state.selectedAnswer == option;
              final isCorrect = option.toLowerCase() ==
                  question.correctAnswer.toLowerCase();
              final isAnswered = state.status == QuizStatus.answered;

              Color? bgColor;
              Color? borderColor;
              if (isAnswered) {
                if (isCorrect) {
                  bgColor = Colors.green.withValues(alpha: 0.1);
                  borderColor = Colors.green;
                } else if (isSelected) {
                  bgColor = Colors.red.withValues(alpha: 0.1);
                  borderColor = Colors.red;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: isAnswered
                      ? null
                      : () => context.read<QuizBloc>().add(AnswerQuestion(option)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: bgColor,
                    side: BorderSide(color: borderColor ??
                        Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(option,
                          style: Theme.of(context).textTheme.bodyLarge)),
                      if (isAnswered && isCorrect)
                        const Icon(Icons.check_circle, color: Colors.green),
                      if (isAnswered && isSelected && !isCorrect)
                        const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ),
                ),
              );
            }),
          if (state.status == QuizStatus.answered) ...[
            const SizedBox(height: 8),
            Card(
              color: state.isCorrect == true
                  ? Colors.green.withValues(alpha: 0.05)
                  : Colors.red.withValues(alpha: 0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(state.isCorrect == true ? Icons.check_circle : Icons.cancel,
                          color: state.isCorrect == true ? Colors.green : Colors.red),
                      const SizedBox(width: 8),
                      Text(state.isCorrect == true ? 'Poprawna odpowiedź!' : 'Błędna odpowiedź',
                          style: TextStyle(fontWeight: FontWeight.bold,
                              color: state.isCorrect == true ? Colors.green : Colors.red)),
                    ]),
                    const SizedBox(height: 8),
                    Text(question.explanation,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
            const Spacer(),
            FilledButton(
              onPressed: () => context.read<QuizBloc>().add(const NextQuestion()),
              child: Text(state.currentIndex + 1 >= quiz.questions.length
                  ? 'Zobacz wyniki' : 'Następne pytanie'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final QuizState state;
  final String subjectId;
  const _ResultsView({required this.state, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    final total = state.quiz!.questions.length;
    final correct = state.correctCount;
    final percent = (correct / total * 100).round();
    final duration = state.startTime != null
        ? DateTime.now().difference(state.startTime!)
        : Duration.zero;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percent >= 70 ? Icons.emoji_events : Icons.school,
              size: 80,
              color: percent >= 70
                  ? Colors.amber
                  : Theme.of(context).colorScheme.primary,
            ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms,
                curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text('$percent%',
                style: Theme.of(context).textTheme.displayLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$correct z $total poprawnych odpowiedzi',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Czas: ${duration.inMinutes}m ${duration.inSeconds % 60}s',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 32),
            Text(
              percent >= 90 ? 'Świetnie! Doskonała znajomość materiału!' :
              percent >= 70 ? 'Dobrze! Jeszcze trochę nauki i będzie perfekcyjnie.' :
              percent >= 50 ? 'Nieźle, ale warto powtórzyć materiał.' :
              'Warto wrócić do materiałów i powtórzyć naukę.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.read<QuizBloc>()
                  .add(GenerateQuizEvent(subjectId: subjectId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Nowy quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
