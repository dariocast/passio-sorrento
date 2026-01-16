/// Tracking Cubit for managing live tracking state.
library;

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tracking_data.dart';
import '../../domain/repositories/tracking_repository.dart';

part 'tracking_state.dart';

/// Cubit for managing live tracking state.
class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit({
    required TrackingRepository repository,
    this.confraternityIdFilter,
  }) : _repository = repository,
       super(const TrackingState());

  final TrackingRepository _repository;

  /// If set, only show tracking data for this confraternity.
  final String? confraternityIdFilter;

  StreamSubscription<List<TrackingData>>? _trackingSubscription;

  /// Starts watching live tracking data.
  void startWatching() {
    emit(state.copyWith(status: TrackingStatus.loading));

    _trackingSubscription?.cancel();
    _trackingSubscription = _repository.watchLiveTrackingData().listen(
      (data) {
        final filteredData = _applyFilter(data);
        emit(
          state.copyWith(
            status: TrackingStatus.success,
            trackingData: filteredData,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: TrackingStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  /// Loads tracking data once.
  Future<void> loadData() async {
    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      final data = await _repository.getLiveTrackingData();
      final filteredData = _applyFilter(data);
      emit(
        state.copyWith(
          status: TrackingStatus.success,
          trackingData: filteredData,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TrackingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Applies the confraternity filter if set.
  List<TrackingData> _applyFilter(List<TrackingData> data) {
    if (confraternityIdFilter == null) return data;
    return data.where((d) => d.processionId == confraternityIdFilter).toList();
  }

  /// Selects a procession to focus on the map.
  void selectProcession(String? processionId) {
    emit(state.copyWith(selectedProcessionId: processionId));
  }

  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    return super.close();
  }
}
