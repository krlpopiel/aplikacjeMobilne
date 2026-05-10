import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure(super.message);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message);
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

class OllamaNotReachableFailure extends Failure {
  const OllamaNotReachableFailure(super.message);
}

class OllamaModelNotFoundFailure extends Failure {
  final String modelName;
  const OllamaModelNotFoundFailure(this.modelName, String message)
      : super(message);
  @override
  List<Object?> get props => [message, modelName];
}

class OllamaStreamFailure extends Failure {
  const OllamaStreamFailure(super.message);
}
