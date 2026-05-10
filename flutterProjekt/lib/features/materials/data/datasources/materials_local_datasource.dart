import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/material_model.dart';

class MaterialsLocalDatasource {
  Box get _box => Hive.box(AppConstants.materialsBox);

  Future<List<MaterialModel>> getMaterialsForSubject(String subjectId) async {
    try {
      final materials = <MaterialModel>[];
      for (final key in _box.keys) {
        final json = Map<String, dynamic>.from(_box.get(key) as Map);
        final model = MaterialModel.fromJson(json);
        if (model.subjectId == subjectId) {
          materials.add(model);
        }
      }
      materials.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return materials;
    } catch (e) {
      throw CacheException('Failed to load materials: $e');
    }
  }

  Future<void> saveMaterial(MaterialModel material) async {
    try {
      await _box.put(material.id, material.toJson());
    } catch (e) {
      throw CacheException('Failed to save material: $e');
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete material: $e');
    }
  }
}
