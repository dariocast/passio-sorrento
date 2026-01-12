part of 'home_cubit.dart';

/// Status for home screen loading.
enum HomeStatus { initial, loading, success, failure }

/// State for the home screen.
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.confraternities = const [],
    this.liveProcessions = const [],
    this.errorMessage,
  });

  /// Current loading status.
  final HomeStatus status;

  /// List of confraternities.
  final List<Confraternity> confraternities;

  /// Currently live processions.
  final List<Procession> liveProcessions;

  /// Error message if any.
  final String? errorMessage;

  /// Creates a copy with updated fields.
  HomeState copyWith({
    HomeStatus? status,
    List<Confraternity>? confraternities,
    List<Procession>? liveProcessions,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      confraternities: confraternities ?? this.confraternities,
      liveProcessions: liveProcessions ?? this.liveProcessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, confraternities, liveProcessions, errorMessage];
}
