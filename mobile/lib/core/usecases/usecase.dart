/// Base use case abstraction for Clean Architecture.
library;

/// Base use case interface.
///
/// [T] is the return type of the use case.
/// [Params] is the type of parameters the use case accepts.
abstract class UseCase<T, Params> {
  /// Executes the use case.
  Future<T> call(Params params);
}

/// No parameters needed for use case.
class NoParams {
  const NoParams();
}
