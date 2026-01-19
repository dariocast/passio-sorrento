/// Main entry point for the Holyweek Tracker app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/data/datasources/home_local_data_source.dart';
import 'features/home/data/repositories/home_repository_cached.dart';
import 'features/home/data/repositories/home_repository_http.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/tracking/data/datasources/tracking_remote_data_source.dart';
import 'features/tracking/data/repositories/tracking_repository_impl.dart';
import 'features/tracking/domain/repositories/tracking_repository.dart';
import 'features/weather/data/datasources/weather_remote_data_source.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/repositories/weather_repository.dart';

void main() {
  runApp(const HolyweekApp());
}

/// Root application widget with dependency injection.
class HolyweekApp extends StatelessWidget {
  const HolyweekApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create shared HTTP client
    final httpClient = http.Client();

    // Create data sources
    final homeLocalDataSource = HomeLocalDataSource();
    final trackingRemoteDataSource = TrackingRemoteDataSource(
      client: httpClient,
    );
    // Note: WeatherRemoteDataSource requires an API key - configure in production
    final weatherRemoteDataSource = WeatherRemoteDataSource(
      apiKey: const String.fromEnvironment(
        'OPENWEATHER_API_KEY',
        defaultValue: 'e6b6d9b20a45455b6b3a7fe7f8d5899c',
      ),
      client: httpClient,
    );

    // Create repository implementations
    // Using HomeRepositoryCached for offline-first access with network fallback
    final homeRemoteRepository = HomeRepositoryHttp(client: httpClient);
    final homeRepository = HomeRepositoryCached(
      remoteRepository: homeRemoteRepository,
      localDataSource: homeLocalDataSource,
    );
    final trackingRepository = TrackingRepositoryImpl(
      remoteDataSource: trackingRemoteDataSource,
    );
    final weatherRepository = WeatherRepositoryImpl(
      remoteDataSource: weatherRemoteDataSource,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepository>.value(value: homeRepository),
        RepositoryProvider<TrackingRepository>.value(value: trackingRepository),
        RepositoryProvider<WeatherRepository>.value(value: weatherRepository),
      ],
      child: MaterialApp.router(
        title: 'Holyweek Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
