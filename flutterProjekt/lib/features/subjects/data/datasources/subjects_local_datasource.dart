import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/subject_model.dart';

class SubjectsLocalDatasource {
  Box get _box => Hive.box(AppConstants.subjectsBox);

  Future<List<SubjectModel>> getSubjects() async {
    try {
      final subjects = <SubjectModel>[];
      for (final key in _box.keys) {
        final json = Map<String, dynamic>.from(_box.get(key) as Map);
        subjects.add(SubjectModel.fromJson(json));
      }
      subjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return subjects;
    } catch (e) {
      throw CacheException('Failed to load subjects: $e');
    }
  }

  Future<SubjectModel> getSubjectById(String id) async {
    try {
      final data = _box.get(id);
      if (data == null) throw const CacheException('Subject not found');
      return SubjectModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to load subject: $e');
    }
  }

  Future<void> saveSubject(SubjectModel subject) async {
    try {
      await _box.put(subject.id, subject.toJson());
    } catch (e) {
      throw CacheException('Failed to save subject: $e');
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete subject: $e');
    }
  }
}
