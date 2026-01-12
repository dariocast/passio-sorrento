/// Home Cubit for managing home screen state.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/confraternity.dart';
import '../../domain/entities/procession.dart';
import '../../domain/repositories/home_repository.dart';

part 'home_state.dart';

/// Cubit for managing home screen state.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState());

  final HomeRepository _repository;

  /// Loads all home data.
  Future<void> loadData() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final confraternities = await _repository.getConfraternities();
      final liveProcessions = await _repository.getLiveProcessions();

      emit(state.copyWith(
        status: HomeStatus.success,
        confraternities: confraternities,
        liveProcessions: liveProcessions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Refreshes data.
  Future<void> refresh() async {
    await loadData();
  }
}
