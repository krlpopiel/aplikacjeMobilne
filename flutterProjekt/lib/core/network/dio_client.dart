import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const NetworkException('Connection timed out'),
              ),
            );
            return;
          }

          if (error.response?.statusCode == 429) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const RateLimitException(
                  'Rate limit exceeded. Please try again later.',
                ),
              ),
            );
            return;
          }

          if (error.response?.statusCode == 401) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const ApiKeyException('Invalid API key'),
              ),
            );
            return;
          }

          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        options: Options(headers: headers, responseType: responseType),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error as Exception;
      throw ServerException(
        e.response?.data?.toString() ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
