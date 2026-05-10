import '../../../../core/utils/result.dart';
import '../entities/subject.dart';
import '../repositories/subjects_repository.dart';

class CreateSubject {
  final SubjectsRepository repository;
  CreateSubject(this.repository);

  Future<Result<Subject>> call({
    required String name,
    String? description,
    required int colorValue,
  }) =>
      repository.createSubject(
        name: name,
        description: description,
        colorValue: colorValue,
      );
}
