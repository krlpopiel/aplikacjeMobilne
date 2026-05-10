import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/ollama_model.dart';

/// Datasource for interacting with the Ollama REST API.
class OllamaRemoteDatasource {
  final Dio _dio;

  OllamaRemoteDatasource()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Fetches the list of models installed on the Ollama instance.
  Future<List<OllamaModel>> fetchInstalledModels(String baseUrl) async {
    try {
      final response = await _dio.get('$baseUrl/api/tags');
      final data = response.data as Map<String, dynamic>;
      final models = (data['models'] as List<dynamic>?)
              ?.map((m) =>
                  OllamaModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
      // Sort by name
      models.sort(
          (a, b) => a.displayName.compareTo(b.displayName));
      return models;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw ServerException(
          'Nie można połączyć z Ollama pod adresem $baseUrl. '
          'Upewnij się, że Ollama jest uruchomiona (ollama serve).',
        );
      }
      throw ServerException(
        'Błąd pobierania modeli Ollama: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Tests connection to Ollama and returns the number of available models.
  Future<int> testConnection(String baseUrl) async {
    try {
      final models = await fetchInstalledModels(baseUrl);
      return models.length;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Nieoczekiwany błąd: $e');
    }
  }
}
