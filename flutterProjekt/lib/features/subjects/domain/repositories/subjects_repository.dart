import '../../../../core/utils/result.dart';
import '../entities/subject.dart';

abstract class SubjectsRepository {
  Future<Result<List<Subject>>> getSubjects();
  Future<Result<Subject>> getSubjectById(String id);
  Future<Result<Subject>> createSubject({
    required String name,
    String? description,
    required int colorValue,
  });
  Future<Result<void>> deleteSubject(String id);
  Future<Result<Subject>> updateSubject(Subject subject);
}
