import '../../../../core/utils/result.dart';
import '../entities/subject.dart';
import '../repositories/subjects_repository.dart';

class GetSubjects {
  final SubjectsRepository repository;
  GetSubjects(this.repository);

  Future<Result<List<Subject>>> call() => repository.getSubjects();
}
