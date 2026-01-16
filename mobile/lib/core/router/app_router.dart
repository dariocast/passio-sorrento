/// App navigation routes.
library;

import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/confraternity_detail_page.dart';
import '../../features/weather/presentation/pages/weather_page.dart';
import '../../features/tracking/presentation/pages/tracking_page.dart';

/// Named routes for the application.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String confraternityDetail = '/confraternity';
  static const String weather = '/weather';
  static const String tracking = '/tracking';
}

/// Route generator for MaterialApp.
class AppRouter {
  AppRouter._();

  /// Generates routes based on [RouteSettings].
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case AppRoutes.confraternityDetail:
        final args = settings.arguments as ConfraternityDetailArgs;
        return MaterialPageRoute(
          builder: (_) => ConfraternityDetailPage(args: args),
          settings: settings,
        );

      case AppRoutes.weather:
        return MaterialPageRoute(
          builder: (_) => const WeatherPage(),
          settings: settings,
        );

      case AppRoutes.tracking:
        return MaterialPageRoute(
          builder: (_) => const TrackingPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

/// Arguments for confraternity detail page.
class ConfraternityDetailArgs {
  const ConfraternityDetailArgs({
    required this.confraternityId,
    required this.confraternityName,
    required this.confraternityColor,
  });

  final String confraternityId;
  final String confraternityName;
  final String confraternityColor;
}
