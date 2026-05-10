import 'dart:convert';
import '../../domain/entities/study_material.dart';

class MaterialModel {
  final String id;
  final String subjectId;
  final String name;
  final String type; // 'pdf' or 'image'
  final String filePath;
  final String chunksJson; // JSON-encoded list of chunks
  final DateTime createdAt;

  MaterialModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.type,
    required this.filePath,
    required this.chunksJson,
    required this.createdAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      filePath: json['filePath'] as String,
      chunksJson: json['chunksJson'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'name': name,
      'type': type,
      'filePath': filePath,
      'chunksJson': chunksJson,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  StudyMaterial toEntity() {
    final chunks = (json.decode(chunksJson) as List<dynamic>)
        .map((e) => e as String)
        .toList();

    return StudyMaterial(
      id: id,
      subjectId: subjectId,
      name: name,
      type: type == 'pdf' ? MaterialType.pdf : MaterialType.image,
      filePath: filePath,
      chunks: chunks,
      createdAt: createdAt,
    );
  }

  factory MaterialModel.fromEntity(StudyMaterial entity) {
    return MaterialModel(
      id: entity.id,
      subjectId: entity.subjectId,
      name: entity.name,
      type: entity.type == MaterialType.pdf ? 'pdf' : 'image',
      filePath: entity.filePath,
      chunksJson: json.encode(entity.chunks),
      createdAt: entity.createdAt,
    );
  }
}
