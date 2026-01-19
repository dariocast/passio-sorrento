/// App shell with adaptive navigation.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../utils/responsive_utils.dart';

/// Navigation destination definition.
class AppDestination {
  const AppDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// List of navigation destinations.
const List<AppDestination> destinations = [
  AppDestination(
    path: AppRoutes.home,
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  AppDestination(
    path: AppRoutes.weather,
    label: 'Meteo',
    icon: Icons.cloud_outlined,
    selectedIcon: Icons.cloud_rounded,
  ),
  AppDestination(
    path: AppRoutes.tracking,
    label: 'Tracking',
    icon: Icons.map_outlined,
    selectedIcon: Icons.map_rounded,
  ),
  AppDestination(
    path: AppRoutes.settings,
    label: 'Impostazioni',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  ),
];

/// App shell widget that wraps content with adaptive navigation.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  /// Get the current selected index based on location.
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < destinations.length; i++) {
      if (location == destinations[i].path) {
        return i;
      }
    }
    return 0;
  }

  /// Navigate to destination.
  void _onDestinationSelected(BuildContext context, int index) {
    context.go(destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = ResponsiveUtils.getBreakpoint(context);
    final currentIndex = _getCurrentIndex(context);

    // Use NavigationRail for tablet and desktop
    if (breakpoint != Breakpoint.compact) {
      return _AdaptiveNavigationRail(
        currentIndex: currentIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
        extended: breakpoint == Breakpoint.expanded,
        child: child,
      );
    }

    // Use bottom NavigationBar for mobile
    return _BottomNavigationShell(
      currentIndex: currentIndex,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      child: child,
    );
  }
}

/// Mobile bottom navigation shell.
class _BottomNavigationShell extends StatelessWidget {
  const _BottomNavigationShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 400),
        destinations: destinations.map((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: Icon(dest.selectedIcon),
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }
}

/// Tablet/Desktop navigation rail shell.
class _AdaptiveNavigationRail extends StatelessWidget {
  const _AdaptiveNavigationRail({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.extended,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            extended: extended,
            minWidth: 72,
            minExtendedWidth: 200,
            useIndicator: true,
            indicatorColor: theme.colorScheme.primaryContainer,
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            leading: _NavigationRailHeader(extended: extended),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _DarkModeToggle(extended: extended),
                ),
              ),
            ),
            destinations: destinations.map((dest) {
              return NavigationRailDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: Text(dest.label),
                padding: const EdgeInsets.symmetric(vertical: 4),
              );
            }).toList(),
          ),
          // Divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Navigation rail header with app logo.
class _NavigationRailHeader extends StatelessWidget {
  const _NavigationRailHeader({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: extended
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.church_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Holyweek',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tracker',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.church_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
    );
  }
}

// ...

/// Dark mode toggle button.
class _DarkModeToggle extends StatelessWidget {
  const _DarkModeToggle({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isDark = theme.brightness == Brightness.dark;
        final icon = isDark
            ? Icons.dark_mode_rounded
            : Icons.light_mode_rounded;
        final label = isDark ? 'Tema scuro' : 'Tema chiaro';

        if (extended) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggleTheme(context, state.themeMode),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return IconButton(
          onPressed: () => _toggleTheme(context, state.themeMode),
          icon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          tooltip: label,
        );
      },
    );
  }

  void _toggleTheme(BuildContext context, AppThemeMode currentMode) {
    final newMode = currentMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    context.read<SettingsCubit>().setThemeMode(newMode);
  }
}
