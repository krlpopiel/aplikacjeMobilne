import 'dart:typed_data';
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
  final String fileName;
  final Uint8List fileBytes;
  const UploadPdfEvent({
    required this.subjectId,
    required this.fileName,
    required this.fileBytes,
  });
  @override
  List<Object?> get props => [subjectId, fileName];
}

class UploadImageEvent extends MaterialsEvent {
  final String subjectId;
  final String fileName;
  final Uint8List fileBytes;
  const UploadImageEvent({
    required this.subjectId,
    required this.fileName,
    required this.fileBytes,
  });
  @override
  List<Object?> get props => [subjectId, fileName];
}

class DeleteMaterialEvent extends MaterialsEvent {
  final String materialId;
  final String subjectId;
  const DeleteMaterialEvent({required this.materialId, required this.subjectId});
  @override
  List<Object?> get props => [materialId, subjectId];
}
