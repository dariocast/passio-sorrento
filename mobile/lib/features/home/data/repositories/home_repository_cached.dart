/// Caching repository wrapper that provides offline-first access.
library;

import '../../domain/entities/confraternity.dart';
import '../../domain/entities/procession.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../models/confraternity_model.dart';
import 'home_repository_http.dart';

/// Repository implementation that caches data locally for offline resilience.
///
/// Strategy:
/// 1. Try to fetch from network
/// 2. On success, cache the data
/// 3. On failure, return cached data if available
class HomeRepositoryCached implements HomeRepository {
  HomeRepositoryCached({
    required HomeRepositoryHttp remoteRepository,
    required HomeLocalDataSource localDataSource,
  }) : _remoteRepository = remoteRepository,
       _localDataSource = localDataSource;

  final HomeRepositoryHttp _remoteRepository;
  final HomeLocalDataSource _localDataSource;

  @override
  Future<List<Confraternity>> getConfraternities() async {
    try {
      // Try network first
      final confraternities = await _remoteRepository.getConfraternities();

      // Cache the successful response
      final models = confraternities
          .map((c) => ConfraternityModel.fromEntity(c))
          .toList();
      await _localDataSource.cacheConfraternities(models);

      return confraternities;
    } catch (e) {
      // On network failure, try cache
      final cached = await _localDataSource.getCachedConfraternities();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      // If no cache, rethrow the original error
      rethrow;
    }
  }

  @override
  Future<List<Procession>> getUpcomingProcessions() async {
    // Processions are time-sensitive, always fetch from network
    return _remoteRepository.getUpcomingProcessions();
  }

  @override
  Future<List<Procession>> getLiveProcessions() async {
    // Live data must always be fresh
    return _remoteRepository.getLiveProcessions();
  }
}
