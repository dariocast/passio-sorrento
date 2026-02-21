import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tracker_app/data/services/config_service.dart';
import 'package:tracker_app/data/services/location_service.dart';
import 'package:tracker_app/data/services/offline_queue_service.dart';
import 'package:tracker_app/domain/entities/confraternity.dart';
import 'package:tracker_app/domain/entities/tracking_config.dart';
import 'package:tracker_app/domain/repositories/tracking_repository.dart';
import 'package:tracker_app/presentation/cubit/tracking_cubit.dart';
import 'package:tracker_app/presentation/cubit/tracking_state.dart';

// --- Mocks ---

class MockConfigService extends Mock implements ConfigService {}

class MockLocationService extends Mock implements LocationService {}

class MockOfflineQueueService extends Mock implements OfflineQueueService {}

class MockTrackingRepository extends Mock implements TrackingRepository {}

// --- Test Data ---

const _testConfig = TrackingConfig(
  confraternityId: 'uuid-1',
  confraternityName: 'Test Confraternity',
  secret: 'capofila123',
  serverUrl: 'http://localhost:5000/api',
  intervalSeconds: 30,
);

const _emptyConfig = TrackingConfig(
  confraternityId: '',
  confraternityName: '',
  secret: 'capofila123',
  serverUrl: 'http://localhost:5000/api',
  intervalSeconds: 30,
);

const _testConfraternity = Confraternity(
  id: 'uuid-1',
  name: 'Test Confraternity',
  color: '#FF0000',
  municipality: 'Sorrento',
);

final _testConfraternities = [_testConfraternity];

void main() {
  late MockConfigService mockConfigService;
  late MockLocationService mockLocationService;
  late MockOfflineQueueService mockOfflineQueue;
  late MockTrackingRepository mockRepository;

  setUp(() {
    registerFallbackValue(TrackingConfig.defaultConfig);
    mockConfigService = MockConfigService();
    mockLocationService = MockLocationService();
    mockOfflineQueue = MockOfflineQueueService();
    mockRepository = MockTrackingRepository();
  });

  TrackingCubit buildCubit() {
    return TrackingCubit(
      configService: mockConfigService,
      locationService: mockLocationService,
      offlineQueueService: mockOfflineQueue,
      repositoryFactory: (_) => mockRepository,
    );
  }

  group('initialize', () {
    blocTest<TrackingCubit, TrackingState>(
      'emits TrackingConfigured when config and confraternities load',
      setUp: () {
        when(
          () => mockConfigService.loadConfig(),
        ).thenAnswer((_) async => _testConfig);
        when(
          () => mockRepository.fetchConfraternities(),
        ).thenAnswer((_) async => _testConfraternities);
      },
      build: buildCubit,
      act: (cubit) => cubit.initialize(),
      expect: () => [
        isA<TrackingConfigured>()
            .having((s) => s.config, 'config', _testConfig)
            .having(
              (s) => s.confraternities,
              'confraternities',
              _testConfraternities,
            ),
      ],
    );

    blocTest<TrackingCubit, TrackingState>(
      'emits TrackingConfigured with empty confraternities on fetch error',
      setUp: () {
        when(
          () => mockConfigService.loadConfig(),
        ).thenAnswer((_) async => _testConfig);
        when(
          () => mockRepository.fetchConfraternities(),
        ).thenThrow(Exception('Network error'));
      },
      build: buildCubit,
      act: (cubit) => cubit.initialize(),
      expect: () => [
        isA<TrackingConfigured>().having(
          (s) => s.confraternities,
          'confraternities',
          isEmpty,
        ),
      ],
    );

    blocTest<TrackingCubit, TrackingState>(
      'emits TrackingError when config loading fails',
      setUp: () {
        when(
          () => mockConfigService.loadConfig(),
        ).thenThrow(Exception('Disk error'));
      },
      build: buildCubit,
      act: (cubit) => cubit.initialize(),
      expect: () => [isA<TrackingError>()],
    );
  });

  group('startTracking', () {
    blocTest<TrackingCubit, TrackingState>(
      'emits error when confraternity not selected',
      setUp: () {
        when(
          () => mockConfigService.loadConfig(),
        ).thenAnswer((_) async => _emptyConfig);
        when(
          () => mockRepository.fetchConfraternities(),
        ).thenAnswer((_) async => _testConfraternities);
      },
      build: buildCubit,
      seed: () => TrackingConfigured(
        config: _emptyConfig,
        confraternities: _testConfraternities,
      ),
      act: (cubit) => cubit.startTracking(),
      expect: () => [
        isA<TrackingConfigured>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ],
    );

    blocTest<TrackingCubit, TrackingState>(
      'emits TrackingActive when permissions granted',
      setUp: () {
        when(
          () => mockLocationService.requestPermission(),
        ).thenAnswer((_) async => PermissionResult(granted: true));
        when(
          () => mockLocationService.startTracking(
            intervalSeconds: any(named: 'intervalSeconds'),
          ),
        ).thenReturn(null);
        when(
          () => mockLocationService.positionStream,
        ).thenAnswer((_) => const Stream.empty());
        when(() => mockOfflineQueue.queueLength).thenAnswer((_) async => 0);
      },
      build: buildCubit,
      seed: () => TrackingConfigured(
        config: _testConfig,
        confraternities: _testConfraternities,
      ),
      act: (cubit) => cubit.startTracking(),
      expect: () => [
        isA<TrackingActive>()
            .having((s) => s.config, 'config', _testConfig)
            .having((s) => s.queuedCount, 'queuedCount', 0),
      ],
    );

    blocTest<TrackingCubit, TrackingState>(
      'emits error when permission is denied',
      setUp: () {
        when(() => mockLocationService.requestPermission()).thenAnswer(
          (_) async =>
              PermissionResult(granted: false, message: 'Permission denied'),
        );
      },
      build: buildCubit,
      seed: () => TrackingConfigured(
        config: _testConfig,
        confraternities: _testConfraternities,
      ),
      act: (cubit) => cubit.startTracking(),
      expect: () => [
        isA<TrackingConfigured>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Permission denied',
        ),
      ],
    );
  });

  group('stopTracking', () {
    blocTest<TrackingCubit, TrackingState>(
      'transitions from TrackingActive to TrackingConfigured',
      setUp: () {
        when(
          () => mockConfigService.loadConfig(),
        ).thenAnswer((_) async => _testConfig);
        when(
          () => mockRepository.fetchConfraternities(),
        ).thenAnswer((_) async => _testConfraternities);
        when(() => mockLocationService.stopTracking()).thenReturn(null);
      },
      build: buildCubit,
      seed: () => TrackingActive(config: _testConfig),
      act: (cubit) => cubit.stopTracking(),
      expect: () => [isA<TrackingConfigured>()],
    );
  });

  group('updateConfig', () {
    blocTest<TrackingCubit, TrackingState>(
      'updates config and persists it',
      setUp: () {
        when(
          () => mockConfigService.saveConfig(any()),
        ).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => TrackingConfigured(
        config: _testConfig,
        confraternities: _testConfraternities,
      ),
      act: (cubit) => cubit.updateConfig(intervalSeconds: 60),
      expect: () => [
        isA<TrackingConfigured>().having(
          (s) => s.config.intervalSeconds,
          'intervalSeconds',
          60,
        ),
      ],
      verify: (_) {
        verify(() => mockConfigService.saveConfig(any())).called(1);
      },
    );
  });
}
