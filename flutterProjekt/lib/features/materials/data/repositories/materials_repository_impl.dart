import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/study_material.dart';
import '../../domain/repositories/materials_repository.dart';
import '../datasources/materials_local_datasource.dart';
import '../models/material_model.dart';

class MaterialsRepositoryImpl implements MaterialsRepository {
  final MaterialsLocalDatasource localDatasource;
  final Uuid _uuid = const Uuid();

  MaterialsRepositoryImpl({required this.localDatasource});

  @override
  Future<Result<List<StudyMaterial>>> getMaterialsForSubject(
      String subjectId) async {
    try {
      final models = await localDatasource.getMaterialsForSubject(subjectId);
      return Success(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<StudyMaterial>> uploadPdf({
    required String subjectId,
    required String name,
    required String filePath,
    required List<String> chunks,
  }) async {
    try {
      final model = MaterialModel(
        id: _uuid.v4(),
        subjectId: subjectId,
        name: name,
        type: 'pdf',
        filePath: filePath,
        chunksJson: json.encode(chunks),
        createdAt: DateTime.now(),
      );
      await localDatasource.saveMaterial(model);
      return Success(model.toEntity());
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<StudyMaterial>> uploadImage({
    required String subjectId,
    required String name,
    required String filePath,
    required List<String> chunks,
  }) async {
    try {
      final model = MaterialModel(
        id: _uuid.v4(),
        subjectId: subjectId,
        name: name,
        type: 'image',
        filePath: filePath,
        chunksJson: json.encode(chunks),
        createdAt: DateTime.now(),
      );
      await localDatasource.saveMaterial(model);
      return Success(model.toEntity());
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteMaterial(String id) async {
    try {
      await localDatasource.deleteMaterial(id);
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<List<String>>> getAllChunksForSubject(String subjectId) async {
    try {
      final models = await localDatasource.getMaterialsForSubject(subjectId);
      final allChunks = <String>[];
      for (final model in models) {
        allChunks.addAll(model.toEntity().chunks);
      }
      return Success(allChunks);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }
}
