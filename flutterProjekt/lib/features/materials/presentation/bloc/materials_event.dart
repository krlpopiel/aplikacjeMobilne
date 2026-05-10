import 'package:equatable/equatable.dart';

sealed class MaterialsEvent extends Equatable {
  const MaterialsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMaterials extends MaterialsEvent {
  final String subjectId;
  const LoadMaterials(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class UploadPdfEvent extends MaterialsEvent {
  final String subjectId;
  final String filePath;
  final String fileName;
  const UploadPdfEvent({
    required this.subjectId,
    required this.filePath,
    required this.fileName,
  });
  @override
  List<Object?> get props => [subjectId, filePath, fileName];
}

class UploadImageEvent extends MaterialsEvent {
  final String subjectId;
  final String filePath;
  final String fileName;
  const UploadImageEvent({
    required this.subjectId,
    required this.filePath,
    required this.fileName,
  });
  @override
  List<Object?> get props => [subjectId, filePath, fileName];
}

class DeleteMaterialEvent extends MaterialsEvent {
  final String materialId;
  final String subjectId;
  const DeleteMaterialEvent({required this.materialId, required this.subjectId});
  @override
  List<Object?> get props => [materialId, subjectId];
}
