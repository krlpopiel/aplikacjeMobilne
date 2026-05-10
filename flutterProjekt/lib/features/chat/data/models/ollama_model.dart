import 'package:equatable/equatable.dart';

class OllamaModel extends Equatable {
  final String name;
  final int size;
  final String modifiedAt;

  const OllamaModel({
    required this.name,
    required this.size,
    required this.modifiedAt,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      name: json['name'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      modifiedAt: json['modified_at'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [name, size, modifiedAt];
}

extension OllamaModelX on OllamaModel {
  /// Display name without tag — "llama3.2:latest" → "llama3.2"
  String get displayName => name.split(':').first;

  /// Tag portion — "llama3.2:latest" → "latest"
  String get tag => name.contains(':') ? name.split(':').last : 'latest';

  /// Human-readable file size
  String get sizeFormatted {
    final gb = size / 1e9;
    return gb >= 1
        ? '${gb.toStringAsFixed(1)} GB'
        : '${(size / 1e6).toStringAsFixed(0)} MB';
  }

  /// Whether this is a large model (70B+) that can handle more context
  bool get isLargeModel {
    final lower = name.toLowerCase();
    return lower.contains('70b') ||
        lower.contains('72b') ||
        lower.contains('65b');
  }
}
