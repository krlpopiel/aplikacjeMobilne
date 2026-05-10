import 'package:equatable/equatable.dart';

enum MaterialType { pdf, image }

class StudyMaterial extends Equatable {
  final String id;
  final String subjectId;
  final String name;
  final MaterialType type;
  final String filePath;
  final List<String> chunks;
  final DateTime createdAt;

  const StudyMaterial({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.type,
    required this.filePath,
    required this.chunks,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, subjectId, name, type, filePath, createdAt];
}
