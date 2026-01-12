/// Home repository interface.
library;

import '../entities/confraternity.dart';
import '../entities/procession.dart';

/// Repository interface for home feature data operations.
abstract class HomeRepository {
  /// Gets all confraternities.
  Future<List<Confraternity>> getConfraternities();

  /// Gets upcoming processions.
  Future<List<Procession>> getUpcomingProcessions();

  /// Gets currently live processions.
  Future<List<Procession>> getLiveProcessions();
}
