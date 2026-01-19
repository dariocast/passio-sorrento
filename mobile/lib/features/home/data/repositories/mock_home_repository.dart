/// Mock implementation of HomeRepository for development.
library;

import '../../domain/entities/confraternity.dart';
import '../../domain/entities/procession.dart';
import '../../domain/repositories/home_repository.dart';

/// Mock implementation of [HomeRepository] that returns hardcoded data.
///
/// This is used during development before the backend is ready.
/// The data structure matches the API reference specification.
class MockHomeRepository implements HomeRepository {
  /// Simulated network delay in milliseconds.
  final int _delayMs;

  MockHomeRepository({int delayMs = 500}) : _delayMs = delayMs;

  @override
  Future<List<Confraternity>> getConfraternities() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _delayMs));

    return const [
      Confraternity(
        id: 'uuid-1',
        name: 'Arciconfraternita della Morte',
        color: '#000000',
        municipality: 'Sorrento',
        coatOfArms: 'https://example.com/coat1.png',
        history:
            'Fondata nel XV secolo, questa arciconfraternita è una delle più antiche della penisola sorrentina.',
      ),
      Confraternity(
        id: 'uuid-2',
        name: 'Confraternita di Santa Monica',
        color: '#2E2E2E',
        municipality: 'Sorrento',
        coatOfArms: 'https://example.com/coat2.png',
        history:
            'La Confraternita di Santa Monica è nota per la sua processione del Venerdì Santo.',
      ),
      Confraternity(
        id: 'uuid-3',
        name: 'Confraternita del SS. Rosario',
        color: '#8B0000',
        municipality: 'Sorrento',
        coatOfArms: 'https://example.com/coat3.png',
        history:
            'Dedicata alla devozione mariana, questa confraternita organizza la processione della Madonna.',
      ),
      Confraternity(
        id: 'uuid-4',
        name: 'Arciconfraternita di San Paolo',
        color: '#4A0082',
        municipality: 'Massa Lubrense',
        coatOfArms: 'https://example.com/coat4.png',
        history:
            'Una delle confraternite più importanti di Massa Lubrense, attiva dalla prima metà del 1500.',
      ),
      Confraternity(
        id: 'uuid-5',
        name: 'Confraternita del Lauro',
        color: '#006400',
        municipality: 'Meta',
        coatOfArms: 'https://example.com/coat5.png',
        history:
            'Situata nell\'antico borgo del Lauro, mantiene vive le tradizioni pasquali metesi.',
      ),
      Confraternity(
        id: 'uuid-6',
        name: 'Confraternita di Sant\'Antonio',
        color: '#1E3A5F',
        municipality: 'Piano di Sorrento',
        coatOfArms: 'https://example.com/coat6.png',
        history:
            'La confraternita è custode della tradizionale processione notturna del Giovedì Santo.',
      ),
    ];
  }

  @override
  Future<List<Procession>> getUpcomingProcessions() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _delayMs));

    // Return empty list for now - processions will be added later
    return const [];
  }

  @override
  Future<List<Procession>> getLiveProcessions() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _delayMs));

    // Return empty list - no live processions during development
    return const [];
  }
}
