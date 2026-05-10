import '../../domain/entities/subject.dart';

class SubjectModel {
  final String id;
  final String name;
  final String? description;
  final int colorValue;
  final DateTime createdAt;

  SubjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.colorValue,
    required this.createdAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      colorValue: json['colorValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Subject toEntity({int materialCount = 0, int conversationCount = 0}) {
    return Subject(
      id: id,
      name: name,
      description: description,
      colorValue: colorValue,
      createdAt: createdAt,
      materialCount: materialCount,
      conversationCount: conversationCount,
    );
  }

  factory SubjectModel.fromEntity(Subject entity) {
    return SubjectModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      colorValue: entity.colorValue,
      createdAt: entity.createdAt,
    );
  }
}
