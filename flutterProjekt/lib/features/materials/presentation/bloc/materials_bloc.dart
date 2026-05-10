import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/pdf_parser_service.dart';
import '../../../../core/services/image_ocr_service.dart';
import '../../domain/usecases/material_usecases.dart';
import 'materials_event.dart';
import 'materials_state.dart';

class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final GetMaterialsForSubject _getMaterials;
  final UploadPdf _uploadPdf;
  final UploadImage _uploadImage;
  final DeleteMaterial _deleteMaterial;
  final PdfParserService _pdfParser;
  final ImageOcrService _imageOcr;
  final FlutterSecureStorage _secureStorage;

  MaterialsBloc({
    required GetMaterialsForSubject getMaterials,
    required UploadPdf uploadPdf,
    required UploadImage uploadImage,
    required DeleteMaterial deleteMaterial,
    required PdfParserService pdfParser,
    required ImageOcrService imageOcr,
    required FlutterSecureStorage secureStorage,
  })  : _getMaterials = getMaterials,
        _uploadPdf = uploadPdf,
        _uploadImage = uploadImage,
        _deleteMaterial = deleteMaterial,
        _pdfParser = pdfParser,
        _imageOcr = imageOcr,
        _secureStorage = secureStorage,
        super(const MaterialsState()) {
    on<LoadMaterials>(_onLoad);
    on<UploadPdfEvent>(_onUploadPdf);
    on<UploadImageEvent>(_onUploadImage);
    on<DeleteMaterialEvent>(_onDelete);
  }

  Future<void> _onLoad(
      LoadMaterials event, Emitter<MaterialsState> emit) async {
    emit(state.copyWith(status: MaterialsStatus.loading));
    final result = await _getMaterials(event.subjectId);
    result.fold(
      onSuccess: (materials) => emit(state.copyWith(
        status: MaterialsStatus.loaded,
        materials: materials,
      )),
      onError: (f) => emit(state.copyWith(
        status: MaterialsStatus.error,
        errorMessage: f.message,
      )),
    );
  }

  Future<void> _onUploadPdf(
      UploadPdfEvent event, Emitter<MaterialsState> emit) async {
    emit(state.copyWith(
      status: MaterialsStatus.uploading,
      uploadingFileName: event.fileName,
    ));

    try {
      final bytes = await File(event.filePath).readAsBytes();
      final chunks = await _pdfParser.parsePdfToChunks(bytes);

      final result = await _uploadPdf(
        subjectId: event.subjectId,
        name: event.fileName,
        filePath: event.filePath,
        chunks: chunks,
      );

      result.fold(
        onSuccess: (_) => add(LoadMaterials(event.subjectId)),
        onError: (f) => emit(state.copyWith(
          status: MaterialsStatus.error,
          errorMessage: f.message,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        status: MaterialsStatus.error,
        errorMessage: 'Błąd parsowania PDF: $e',
      ));
    }
  }

  Future<void> _onUploadImage(
      UploadImageEvent event, Emitter<MaterialsState> emit) async {
    emit(state.copyWith(
      status: MaterialsStatus.uploading,
      uploadingFileName: event.fileName,
    ));

    try {
      final providerStr =
          await _secureStorage.read(key: AppConstants.apiProviderKey);
      final apiKey =
          await _secureStorage.read(key: AppConstants.apiKeyKey);

      if (apiKey == null || apiKey.isEmpty) {
        emit(state.copyWith(
          status: MaterialsStatus.error,
          errorMessage: 'Brak klucza API. Skonfiguruj go w ustawieniach.',
        ));
        return;
      }

      final provider = providerStr == 'openai'
          ? AiProvider.openai
          : AiProvider.anthropic;

      final bytes = await File(event.filePath).readAsBytes();
      final chunks = await _imageOcr.extractTextFromImage(
        bytes,
        provider: provider,
        apiKey: apiKey,
      );

      final result = await _uploadImage(
        subjectId: event.subjectId,
        name: event.fileName,
        filePath: event.filePath,
        chunks: chunks,
      );

      result.fold(
        onSuccess: (_) => add(LoadMaterials(event.subjectId)),
        onError: (f) => emit(state.copyWith(
          status: MaterialsStatus.error,
          errorMessage: f.message,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        status: MaterialsStatus.error,
        errorMessage: 'Błąd przetwarzania obrazu: $e',
      ));
    }
  }

  Future<void> _onDelete(
      DeleteMaterialEvent event, Emitter<MaterialsState> emit) async {
    final result = await _deleteMaterial(event.materialId);
    result.fold(
      onSuccess: (_) => add(LoadMaterials(event.subjectId)),
      onError: (f) => emit(state.copyWith(
        status: MaterialsStatus.error,
        errorMessage: f.message,
      )),
    );
  }
}
