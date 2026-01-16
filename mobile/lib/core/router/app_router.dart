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
        final args = settings.arguments as WeatherPageArgs?;
        return MaterialPageRoute(
          builder: (_) => WeatherPage(args: args),
          settings: settings,
        );

      case AppRoutes.tracking:
        final args = settings.arguments as TrackingPageArgs?;
        return MaterialPageRoute(
          builder: (_) => TrackingPage(args: args),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
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

/// Arguments for tracking page.
class TrackingPageArgs {
  const TrackingPageArgs({
    this.confraternityId,
    this.confraternityName,
    this.confraternityColor,
  });

  /// If null, show all active processions.
  /// If provided, filter to only this confraternity.
  final String? confraternityId;
  final String? confraternityName;
  final String? confraternityColor;
}

/// Arguments for weather page.
class WeatherPageArgs {
  const WeatherPageArgs({this.initialMunicipality});

  /// Municipality to show initially. If null, shows first tab.
  final String? initialMunicipality;
}
