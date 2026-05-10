import '../../../../core/utils/result.dart';
import '../entities/study_material.dart';
import '../repositories/materials_repository.dart';

class UploadPdf {
  final MaterialsRepository repository;
  UploadPdf(this.repository);

  Future<Result<StudyMaterial>> call({
    required String subjectId,
    required String name,
    required String filePath,
    required List<String> chunks,
  }) =>
      repository.uploadPdf(
        subjectId: subjectId,
        name: name,
        filePath: filePath,
        chunks: chunks,
      );
}

class UploadImage {
  final MaterialsRepository repository;
  UploadImage(this.repository);

  Future<Result<StudyMaterial>> call({
    required String subjectId,
    required String name,
    required String filePath,
    required List<String> chunks,
  }) =>
      repository.uploadImage(
        subjectId: subjectId,
        name: name,
        filePath: filePath,
        chunks: chunks,
      );
}

class GetMaterialsForSubject {
  final MaterialsRepository repository;
  GetMaterialsForSubject(this.repository);

  Future<Result<List<StudyMaterial>>> call(String subjectId) =>
      repository.getMaterialsForSubject(subjectId);
}

class DeleteMaterial {
  final MaterialsRepository repository;
  DeleteMaterial(this.repository);

  Future<Result<void>> call(String id) => repository.deleteMaterial(id);
}
