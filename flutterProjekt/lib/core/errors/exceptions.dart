class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class ApiKeyException implements Exception {
  final String message;
  const ApiKeyException(this.message);
}

class RateLimitException implements Exception {
  final String message;
  const RateLimitException(this.message);
}

class ParsingException implements Exception {
  final String message;
  const ParsingException(this.message);
}
