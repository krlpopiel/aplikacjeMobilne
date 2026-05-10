import 'package:equatable/equatable.dart';

sealed class SubjectsEvent extends Equatable {
  const SubjectsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubjects extends SubjectsEvent {
  const LoadSubjects();
}

class AddSubject extends SubjectsEvent {
  final String name;
  final String? description;
  final int colorValue;

  const AddSubject({
    required this.name,
    this.description,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [name, description, colorValue];
}

class RemoveSubject extends SubjectsEvent {
  final String id;
  const RemoveSubject(this.id);

  @override
  List<Object?> get props => [id];
}
