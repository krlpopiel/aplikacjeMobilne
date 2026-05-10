import '../../../../core/utils/result.dart';
import '../entities/study_material.dart';

abstract class MaterialsRepository {
  Future<Result<List<StudyMaterial>>> getMaterialsForSubject(String subjectId);
  Future<Result<StudyMaterial>> uploadPdf({
    required String subjectId,
    required String name,
    required String filePath,
    required List<String> chunks,
  });
  Future<Result<StudyMaterial>> uploadImage({
    required String subjectId,
    required String name,
    required String filePath,
    required List<String> chunks,
  });
  Future<Result<void>> deleteMaterial(String id);
  Future<Result<List<String>>> getAllChunksForSubject(String subjectId);
}
