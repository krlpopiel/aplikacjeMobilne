import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int colorValue;
  final DateTime createdAt;
  final int materialCount;
  final int conversationCount;

  const Subject({
    required this.id,
    required this.name,
    this.description,
    required this.colorValue,
    required this.createdAt,
    this.materialCount = 0,
    this.conversationCount = 0,
  });

  Subject copyWith({
    String? id,
    String? name,
    String? description,
    int? colorValue,
    DateTime? createdAt,
    int? materialCount,
    int? conversationCount,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      materialCount: materialCount ?? this.materialCount,
      conversationCount: conversationCount ?? this.conversationCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        colorValue,
        createdAt,
        materialCount,
        conversationCount,
      ];
}
