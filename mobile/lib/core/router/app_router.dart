/// App navigation routes using go_router.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/confraternity_detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/tracking/presentation/pages/tracking_page.dart';
import '../../features/weather/presentation/pages/weather_page.dart';
import '../navigation/app_shell.dart';

/// Route path constants.
abstract final class AppRoutes {
  // Shell routes (tabs)
  static const String home = '/';
  static const String weather = '/weather';
  static const String tracking = '/tracking';
  static const String settings = '/settings';

  // Detail routes
  static const String confraternityDetail = '/confraternity/:id';

  /// Helper to build confraternity detail path.
  static String confraternityPath(String id) => '/confraternity/$id';
}

/// Route name constants for named navigation.
abstract final class RouteNames {
  static const String home = 'home';
  static const String weather = 'weather';
  static const String tracking = 'tracking';
  static const String settings = 'settings';
  static const String confraternityDetail = 'confraternityDetail';
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

/// Main router configuration.
class AppRouter {
  AppRouter._();

  /// Global navigator key for root navigator.
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Shell navigator key for tab navigation.
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  /// The main router instance.
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: AppRoutes.home,
            name: RouteNames.home,
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const HomePage(),
            ),
          ),
          // Weather tab
          GoRoute(
            path: AppRoutes.weather,
            name: RouteNames.weather,
            pageBuilder: (context, state) {
              final args = state.extra as WeatherPageArgs?;
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: WeatherPage(args: args),
              );
            },
          ),
          // Tracking tab
          GoRoute(
            path: AppRoutes.tracking,
            name: RouteNames.tracking,
            pageBuilder: (context, state) {
              final args = state.extra as TrackingPageArgs?;
              return _buildPageWithTransition(
                context: context,
                state: state,
                child: TrackingPage(args: args),
              );
            },
          ),
          // Settings tab
          GoRoute(
            path: AppRoutes.settings,
            name: RouteNames.settings,
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),
      // Detail routes (outside shell - full screen)
      GoRoute(
        path: AppRoutes.confraternityDetail,
        name: RouteNames.confraternityDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as ConfraternityDetailArgs;
          return _buildSlideTransition(
            context: context,
            state: state,
            child: ConfraternityDetailPage(args: args),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// Build a fade transition page.
  static Page<void> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  /// Build a slide transition page.
  static Page<void> _buildSlideTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

/// Extension for convenient navigation.
extension AppRouterExtension on BuildContext {
  /// Navigate to confraternity detail.
  void goToConfraternity(ConfraternityDetailArgs args) {
    pushNamed(
      RouteNames.confraternityDetail,
      pathParameters: {'id': args.confraternityId},
      extra: args,
    );
  }

  /// Navigate to weather page.
  void goToWeather({String? municipality}) {
    go(
      AppRoutes.weather,
      extra: municipality != null
          ? WeatherPageArgs(initialMunicipality: municipality)
          : null,
    );
  }

  /// Navigate to tracking page.
  void goToTracking({TrackingPageArgs? args}) {
    go(AppRoutes.tracking, extra: args);
  }
}
