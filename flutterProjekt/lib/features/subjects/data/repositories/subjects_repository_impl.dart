import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subjects_repository.dart';
import '../datasources/subjects_local_datasource.dart';
import '../models/subject_model.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  final SubjectsLocalDatasource localDatasource;
  final Uuid _uuid = const Uuid();

  SubjectsRepositoryImpl({required this.localDatasource});

  @override
  Future<Result<List<Subject>>> getSubjects() async {
    try {
      final models = await localDatasource.getSubjects();
      final subjects = <Subject>[];

      for (final model in models) {
        final matCount = _countMaterials(model.id);
        final convCount = _countConversations(model.id);
        subjects.add(
          model.toEntity(
            materialCount: matCount,
            conversationCount: convCount,
          ),
        );
      }

      return Success(subjects);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<Subject>> getSubjectById(String id) async {
    try {
      final model = await localDatasource.getSubjectById(id);
      return Success(model.toEntity(
        materialCount: _countMaterials(id),
        conversationCount: _countConversations(id),
      ));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<Subject>> createSubject({
    required String name,
    String? description,
    required int colorValue,
  }) async {
    try {
      final model = SubjectModel(
        id: _uuid.v4(),
        name: name,
        description: description,
        colorValue: colorValue,
        createdAt: DateTime.now(),
      );
      await localDatasource.saveSubject(model);
      return Success(model.toEntity());
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteSubject(String id) async {
    try {
      await localDatasource.deleteSubject(id);
      // Clean up materials, conversations
      _cleanupSubjectData(id);
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<Subject>> updateSubject(Subject subject) async {
    try {
      final model = SubjectModel.fromEntity(subject);
      await localDatasource.saveSubject(model);
      return Success(subject);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  int _countMaterials(String subjectId) {
    try {
      final box = Hive.box(AppConstants.materialsBox);
      return box.values
          .where((v) {
            final map = Map<String, dynamic>.from(v as Map);
            return map['subjectId'] == subjectId;
          })
          .length;
    } catch (_) {
      return 0;
    }
  }

  int _countConversations(String subjectId) {
    try {
      final box = Hive.box(AppConstants.conversationsBox);
      return box.values
          .where((v) {
            final map = Map<String, dynamic>.from(v as Map);
            return map['subjectId'] == subjectId;
          })
          .length;
    } catch (_) {
      return 0;
    }
  }

  void _cleanupSubjectData(String subjectId) {
    try {
      final materialsBox = Hive.box(AppConstants.materialsBox);
      final keysToDelete = <dynamic>[];
      for (final key in materialsBox.keys) {
        final map = Map<String, dynamic>.from(materialsBox.get(key) as Map);
        if (map['subjectId'] == subjectId) keysToDelete.add(key);
      }
      materialsBox.deleteAll(keysToDelete);

      final convBox = Hive.box(AppConstants.conversationsBox);
      final convKeysToDelete = <dynamic>[];
      for (final key in convBox.keys) {
        final map = Map<String, dynamic>.from(convBox.get(key) as Map);
        if (map['subjectId'] == subjectId) convKeysToDelete.add(key);
      }
      convBox.deleteAll(convKeysToDelete);
    } catch (_) {}
  }
}
