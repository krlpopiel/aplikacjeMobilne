import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/flashcards_bloc.dart';

class FlashcardsPage extends StatefulWidget {
  final String subjectId;
  const FlashcardsPage({super.key, required this.subjectId});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    context.read<FlashcardsBloc>().add(LoadFlashcards(widget.subjectId));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiszki'),
        centerTitle: true,
      ),
      body: BlocConsumer<FlashcardsBloc, FlashcardsState>(
        listener: (context, state) {
          if (state.isFlipped) {
            _flipController.forward();
          } else {
            _flipController.reverse();
          }
        },
        builder: (context, state) {
          if (state.status == FlashcardsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FlashcardsStatus.generating) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generowanie fiszek z AI...'),
                ],
              ),
            );
          }
          if (state.status == FlashcardsStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Błąd'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.read<FlashcardsBloc>()
                        .add(LoadFlashcards(widget.subjectId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          }
          if (state.flashcards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 80,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Brak fiszek',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Wygeneruj fiszki z materiałów'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.read<FlashcardsBloc>().add(
                        GenerateFlashcardsEvent(subjectId: widget.subjectId)),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generuj fiszki'),
                  ),
                ],
              ),
            );
          }

          final card = state.flashcards[state.currentIndex];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${state.currentIndex + 1} / ${state.flashcards.length}',
                        style: Theme.of(context).textTheme.titleMedium),
                    _DifficultyChip(difficulty: card.difficulty),
                  ],
                ),
              ),
              LinearProgressIndicator(
                value: (state.currentIndex + 1) / state.flashcards.length,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<FlashcardsBloc>().add(const FlipCard()),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final angle = _flipAnimation.value * pi;
                        final showBack = _flipAnimation.value > 0.5;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: showBack
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _CardFace(
                                    text: card.back,
                                    label: 'ODPOWIEDŹ',
                                    color: Theme.of(context).colorScheme.tertiary,
                                  ),
                                )
                              : _CardFace(
                                  text: card.front,
                                  label: 'PYTANIE',
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (state.isFlipped) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('Jak dobrze znałeś odpowiedź?',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RatingButton(label: 'Nie wiem', quality: 1, color: Colors.red,
                          onTap: () => context.read<FlashcardsBloc>().add(const NextCard(1))),
                      _RatingButton(label: 'Słabo', quality: 2, color: Colors.orange,
                          onTap: () => context.read<FlashcardsBloc>().add(const NextCard(2))),
                      _RatingButton(label: 'OK', quality: 3, color: Colors.amber,
                          onTap: () => context.read<FlashcardsBloc>().add(const NextCard(3))),
                      _RatingButton(label: 'Dobrze', quality: 4, color: Colors.lightGreen,
                          onTap: () => context.read<FlashcardsBloc>().add(const NextCard(4))),
                      _RatingButton(label: 'Super', quality: 5, color: Colors.green,
                          onTap: () => context.read<FlashcardsBloc>().add(const NextCard(5))),
                    ],
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Text('Stuknij kartę aby zobaczyć odpowiedź',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: FilledButton.icon(
                  onPressed: () => context.read<FlashcardsBloc>().add(
                      GenerateFlashcardsEvent(subjectId: widget.subjectId)),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generuj więcej fiszek'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text;
  final String label;
  final Color color;
  const _CardFace({required this.text, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: color, letterSpacing: 2)),
            const SizedBox(height: 24),
            Text(text, style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (difficulty) {
      'easy' => (Colors.green, 'Łatwe'),
      'hard' => (Colors.red, 'Trudne'),
      _ => (Colors.orange, 'Średnie'),
    };
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final int quality;
  final Color color;
  final VoidCallback onTap;
  const _RatingButton({required this.label, required this.quality,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 12,
            fontWeight: FontWeight.w600)),
      ),
    );
  }
}
