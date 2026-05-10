import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final String type; // multiple_choice, true_false, open
  final List<String>? options;
  final String correctAnswer;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  @override
  List<Object?> get props => [id, question, type, options, correctAnswer, explanation];
}

class Quiz extends Equatable {
  final String title;
  final List<QuizQuestion> questions;

  const Quiz({required this.title, required this.questions});

  @override
  List<Object?> get props => [title, questions];
}
