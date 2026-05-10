import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../chat/data/datasources/ollama_remote_datasource.dart';
import '../../../chat/data/models/ollama_model.dart';

class GetOllamaModels {
  final OllamaRemoteDatasource _datasource;

  GetOllamaModels(this._datasource);

  Future<Result<List<OllamaModel>>> call(String baseUrl) async {
    try {
      final models = await _datasource.fetchInstalledModels(baseUrl);
      return Success(models);
    } on ServerException catch (e) {
      return Error(OllamaNotReachableFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Nieoczekiwany błąd: $e'));
    }
  }
}
