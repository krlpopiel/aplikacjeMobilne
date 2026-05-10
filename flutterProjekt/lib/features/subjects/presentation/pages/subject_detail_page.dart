import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subjects_repository.dart';

class SubjectDetailPage extends StatefulWidget {
  final String subjectId;

  const SubjectDetailPage({super.key, required this.subjectId});

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  Subject? _subject;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubject();
  }

  Future<void> _loadSubject() async {
    final result =
        await GetIt.I<SubjectsRepository>().getSubjectById(widget.subjectId);
    result.fold(
      onSuccess: (subject) {
        if (mounted) setState(() {
          _subject = subject;
          _loading = false;
        });
      },
      onError: (_) {
        if (mounted) setState(() => _loading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final subject = _subject;
    if (subject == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Nie znaleziono przedmiotu')),
      );
    }

    final color = Color(subject.colorValue);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              subject.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (subject.description != null) ...[
                  Text(
                    subject.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.description_rounded,
                        label: 'Materiały',
                        value: '${subject.materialCount}',
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.chat_rounded,
                        label: 'Rozmowy',
                        value: '${subject.conversationCount}',
                        color: color,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

                const SizedBox(height: 32),

                Text(
                  'Narzędzia nauki',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                _ToolCard(
                  icon: Icons.upload_file_rounded,
                  title: 'Materiały',
                  subtitle: 'Wgraj PDF-y lub zdjęcia notatek',
                  color: color,
                  onTap: () =>
                      context.push('/subjects/${subject.id}/materials'),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: 0.05),

                const SizedBox(height: 12),

                _ToolCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Czat z AI',
                  subtitle: 'Rozmawiaj o swoich materiałach',
                  color: color,
                  onTap: () => context.push('/subjects/${subject.id}/chat'),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(begin: 0.05),

                const SizedBox(height: 12),

                _ToolCard(
                  icon: Icons.style_rounded,
                  title: 'Fiszki',
                  subtitle: 'Generuj fiszki z materiałów',
                  color: color,
                  onTap: () =>
                      context.push('/subjects/${subject.id}/flashcards'),
                ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideX(begin: 0.05),

                const SizedBox(height: 12),

                _ToolCard(
                  icon: Icons.quiz_rounded,
                  title: 'Quiz',
                  subtitle: 'Sprawdź swoją wiedzę',
                  color: color,
                  onTap: () => context.push('/subjects/${subject.id}/quiz'),
                ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideX(begin: 0.05),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
