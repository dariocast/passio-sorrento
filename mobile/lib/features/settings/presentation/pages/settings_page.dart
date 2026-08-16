import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/components/components.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildThemeSection(context, theme),
          const SizedBox(height: AppSpacing.md),
          _buildCacheSection(context, theme),
          const SizedBox(height: AppSpacing.md),
          _buildAboutSection(context, theme),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeData theme) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Aspetto e Tema',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Column(
                children: AppThemeMode.values.map((mode) {
                  final isSelected = state.themeMode == mode;
                  return ListTile(
                    leading: Icon(
                      _getIconForMode(mode),
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(mode.label),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                        : Icon(Icons.circle_outlined, color: theme.colorScheme.outlineVariant),
                    onTap: () {
                      context.read<SettingsCubit>().setThemeMode(mode);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCacheSection(BuildContext context, ThemeData theme) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.storage_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Memoria e Dati',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Svuota cache locale'),
            subtitle: const Text('Cancella i dati scaricati delle confraternite'),
            trailing: const Icon(Icons.cleaning_services_rounded),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache locale svuotata con successo')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Informazioni App',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text(AppConstants.appName),
            subtitle: Text(AppConstants.taglineIt),
            trailing: Text('v0.4.0', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('Mappe e Meteo'),
            subtitle: Text('OpenStreetMap & OpenWeatherMap'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}
