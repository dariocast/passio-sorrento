/// Core failure classes for error handling.
library;

import 'package:equatable/equatable.dart';

/// Base failure class.
abstract class Failure extends Equatable {
  const Failure({this.message});

  /// Human-readable error message.
  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Server-related failure.
class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

/// Network-related failure (no connection).
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Cache-related failure.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error'});
}

/// General unknown failure.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'});
}
