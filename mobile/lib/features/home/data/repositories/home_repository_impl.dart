/// Home repository implementation.
library;

import '../../domain/entities/confraternity.dart';
import '../../domain/entities/procession.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

/// Implementation of [HomeRepository].
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required HomeRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<List<Confraternity>> getConfraternities() async {
    final data = await _remoteDataSource.getConfraternities();
    return data.map((json) => _confraternityFromJson(json)).toList();
  }

  @override
  Future<List<Procession>> getUpcomingProcessions() async {
    // TODO: Implement with proper endpoint
    return [];
  }

  @override
  Future<List<Procession>> getLiveProcessions() async {
    final data = await _remoteDataSource.getLiveProcessions();
    return data.map((json) => _processionFromJson(json)).toList();
  }

  Confraternity _confraternityFromJson(Map<String, dynamic> json) {
    return Confraternity(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      municipality: json['municipality'] as String,
      coatOfArms: json['coat_of_arms'] as String?,
      history: json['history'] as String?,
    );
  }

  Procession _processionFromJson(Map<String, dynamic> json) {
    return Procession(
      id: json['id'] as String,
      confraternityId: json['confraternity_id'] as String,
      day: json['day'] as String,
      exitTime: DateTime.parse(json['exit_time'] as String),
      expectedReturnTime: json['expected_return_time'] != null
          ? DateTime.parse(json['expected_return_time'] as String)
          : null,
      isLive: json['is_live'] as bool? ?? false,
    );
  }
}
