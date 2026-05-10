import '../../../../core/utils/result.dart';
import '../repositories/subjects_repository.dart';

class DeleteSubject {
  final SubjectsRepository repository;
  DeleteSubject(this.repository);

  Future<Result<void>> call(String id) => repository.deleteSubject(id);
}
