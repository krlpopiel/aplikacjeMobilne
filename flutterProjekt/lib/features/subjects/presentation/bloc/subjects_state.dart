import 'package:equatable/equatable.dart';
import '../../domain/entities/subject.dart';

enum SubjectsStatus { initial, loading, loaded, error }

class SubjectsState extends Equatable {
  final SubjectsStatus status;
  final List<Subject> subjects;
  final String? errorMessage;

  const SubjectsState({
    this.status = SubjectsStatus.initial,
    this.subjects = const [],
    this.errorMessage,
  });

  SubjectsState copyWith({
    SubjectsStatus? status,
    List<Subject>? subjects,
    String? errorMessage,
  }) {
    return SubjectsState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subjects, errorMessage];
}
