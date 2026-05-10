import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../chat/data/datasources/ollama_remote_datasource.dart';

class TestOllamaConnection {
  final OllamaRemoteDatasource _datasource;

  TestOllamaConnection(this._datasource);

  /// Tests the connection and returns the number of detected models.
  Future<Result<int>> call(String baseUrl) async {
    try {
      final count = await _datasource.testConnection(baseUrl);
      return Success(count);
    } on ServerException catch (e) {
      return Error(OllamaNotReachableFailure(e.message));
    } catch (e) {
      return Error(OllamaNotReachableFailure(
        'Nie można połączyć z Ollama pod adresem $baseUrl. '
        'Upewnij się, że Ollama jest uruchomiona (ollama serve).',
      ));
    }
  }
}
