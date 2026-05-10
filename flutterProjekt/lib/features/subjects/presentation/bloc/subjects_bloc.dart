import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_subjects.dart';
import '../../domain/usecases/create_subject.dart';
import '../../domain/usecases/delete_subject.dart';
import 'subjects_event.dart';
import 'subjects_state.dart';

class SubjectsBloc extends Bloc<SubjectsEvent, SubjectsState> {
  final GetSubjects _getSubjects;
  final CreateSubject _createSubject;
  final DeleteSubject _deleteSubject;

  SubjectsBloc({
    required GetSubjects getSubjects,
    required CreateSubject createSubject,
    required DeleteSubject deleteSubject,
  })  : _getSubjects = getSubjects,
        _createSubject = createSubject,
        _deleteSubject = deleteSubject,
        super(const SubjectsState()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<AddSubject>(_onAddSubject);
    on<RemoveSubject>(_onRemoveSubject);
  }

  Future<void> _onLoadSubjects(
    LoadSubjects event,
    Emitter<SubjectsState> emit,
  ) async {
    emit(state.copyWith(status: SubjectsStatus.loading));

    final result = await _getSubjects();
    result.fold(
      onSuccess: (subjects) {
        emit(state.copyWith(
          status: SubjectsStatus.loaded,
          subjects: subjects,
        ));
      },
      onError: (failure) {
        emit(state.copyWith(
          status: SubjectsStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> _onAddSubject(
    AddSubject event,
    Emitter<SubjectsState> emit,
  ) async {
    final result = await _createSubject(
      name: event.name,
      description: event.description,
      colorValue: event.colorValue,
    );

    result.fold(
      onSuccess: (_) => add(const LoadSubjects()),
      onError: (failure) {
        emit(state.copyWith(
          status: SubjectsStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> _onRemoveSubject(
    RemoveSubject event,
    Emitter<SubjectsState> emit,
  ) async {
    final result = await _deleteSubject(event.id);

    result.fold(
      onSuccess: (_) => add(const LoadSubjects()),
      onError: (failure) {
        emit(state.copyWith(
          status: SubjectsStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }
}
