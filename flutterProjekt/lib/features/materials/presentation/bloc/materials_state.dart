import 'package:equatable/equatable.dart';
import '../../domain/entities/study_material.dart';

enum MaterialsStatus { initial, loading, loaded, uploading, error }

class MaterialsState extends Equatable {
  final MaterialsStatus status;
  final List<StudyMaterial> materials;
  final String? errorMessage;
  final String? uploadingFileName;

  const MaterialsState({
    this.status = MaterialsStatus.initial,
    this.materials = const [],
    this.errorMessage,
    this.uploadingFileName,
  });

  MaterialsState copyWith({
    MaterialsStatus? status,
    List<StudyMaterial>? materials,
    String? errorMessage,
    String? uploadingFileName,
  }) {
    return MaterialsState(
      status: status ?? this.status,
      materials: materials ?? this.materials,
      errorMessage: errorMessage,
      uploadingFileName: uploadingFileName,
    );
  }

  @override
  List<Object?> get props => [status, materials, errorMessage, uploadingFileName];
}
