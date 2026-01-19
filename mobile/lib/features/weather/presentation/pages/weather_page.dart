/// Weather page widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/components/components.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/weather_repository.dart';
import '../cubit/weather_cubit.dart';

/// Page showing weather forecasts for Sorrento Peninsula municipalities.
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key, this.args});

  final WeatherPageArgs? args;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.args?.initialMunicipality != null
        ? AppConstants.municipalities.indexOf(widget.args!.initialMunicipality!)
        : 0;
    _tabController = TabController(
      length: AppConstants.municipalities.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WeatherCubit(repository: context.read<WeatherRepository>())
            ..loadWeather(
              widget.args?.initialMunicipality ??
                  AppConstants.municipalities.first,
            ),
      child: _WeatherPageContent(tabController: _tabController),
    );
  }
}

class _WeatherPageContent extends StatelessWidget {
  const _WeatherPageContent({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            title: const Text('Meteo'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: theme.colorScheme.surface,
                child: TabBar(
                  controller: tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  tabs: AppConstants.municipalities.map((m) {
                    final color = AppColors.getMunicipalityColor(m);
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(m),
                        ],
                      ),
                    );
                  }).toList(),
                  onTap: (index) {
                    context.read<WeatherCubit>().selectMunicipality(
                      AppConstants.municipalities[index],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
        body: BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            switch (state.status) {
              case WeatherStatus.initial:
              case WeatherStatus.loading:
                return const LoadingState(useSkeleton: true);

              case WeatherStatus.failure:
                return ErrorState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Impossibile caricare il meteo',
                  message: state.errorMessage,
                  onRetry: () => context.read<WeatherCubit>().loadWeather(
                    state.selectedMunicipality ??
                        AppConstants.municipalities.first,
                  ),
                );

              case WeatherStatus.success:
                final weather = state.currentWeather;
                if (weather == null) {
                  return const EmptyState(
                    icon: Icons.cloud_queue_rounded,
                    title: 'Nessun dato meteo',
                    message: 'I dati meteo non sono disponibili al momento.',
                  );
                }

                return _buildWeatherContent(context, state, weather);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeatherContent(
    BuildContext context,
    WeatherState state,
    dynamic weather,
  ) {
    final theme = Theme.of(context);
    final municipalityColor = AppColors.getMunicipalityColor(
      weather.municipality,
    );

    return RefreshIndicator(
      onRefresh: () =>
          context.read<WeatherCubit>().loadWeather(weather.municipality),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current weather card with gradient
            _CurrentWeatherCard(
              weather: weather,
              municipalityColor: municipalityColor,
            ),
            const SizedBox(height: AppSpacing.md),

            // Precipitation probability card
            _PrecipitationCard(weather: weather),
            const SizedBox(height: AppSpacing.lg),

            // Weather metrics grid
            _WeatherMetricsGrid(weather: weather),
            const SizedBox(height: AppSpacing.lg),

            // Forecast section
            if (state.forecast.isNotEmpty) ...[
              Text(
                'Previsioni orarie',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.forecast.take(12).length,
                  itemBuilder: (context, index) {
                    final forecast = state.forecast[index];
                    return _HourlyForecastCard(forecast: forecast);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Daily forecast list
              Text(
                'Previsioni giornaliere',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...state.forecast
                  .take(5)
                  .map((f) => _DailyForecastTile(forecast: f)),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

/// Current weather display card.
class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({
    required this.weather,
    required this.municipalityColor,
  });

  final dynamic weather;
  final Color municipalityColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [municipalityColor, municipalityColor.withAlpha(180)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: municipalityColor.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Municipality name
          Text(
            weather.municipality,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Temperature and icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_weatherIcon(weather.icon), size: 72, color: Colors.white),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    weather.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withAlpha(220),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _weatherIcon(String iconCode) {
    if (iconCode.contains('01')) return Icons.wb_sunny_rounded;
    if (iconCode.contains('02')) return Icons.cloud_queue_rounded;
    if (iconCode.contains('03') || iconCode.contains('04')) {
      return Icons.cloud_rounded;
    }
    if (iconCode.contains('09') || iconCode.contains('10')) {
      return Icons.grain_rounded;
    }
    if (iconCode.contains('11')) return Icons.flash_on_rounded;
    if (iconCode.contains('13')) return Icons.ac_unit_rounded;
    if (iconCode.contains('50')) return Icons.blur_on_rounded;
    return Icons.cloud_rounded;
  }
}

/// Precipitation probability card.
class _PrecipitationCard extends StatelessWidget {
  const _PrecipitationCard({required this.weather});

  final dynamic weather;

  @override
  Widget build(BuildContext context) {
    final isHighProbability = weather.precipitationProbability > 50;

    return StatusCard(
      icon: Icons.water_drop_rounded,
      title: 'Probabilità Pioggia',
      subtitle: isHighProbability
          ? 'Alta probabilità di pioggia'
          : 'Bassa probabilità di pioggia',
      status: isHighProbability ? CardStatus.warning : CardStatus.success,
      action: Text(
        '${weather.precipitationProbability}%',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isHighProbability ? AppColors.warning : AppColors.success,
        ),
      ),
    );
  }
}

/// Weather metrics grid.
class _WeatherMetricsGrid extends StatelessWidget {
  const _WeatherMetricsGrid({required this.weather});

  final dynamic weather;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.water_drop_outlined,
            label: 'Umidità',
            value: '${weather.humidity}%',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricCard(
            icon: Icons.air_rounded,
            label: 'Vento',
            value: '${weather.windSpeed.round()} m/s',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricCard(
            icon: Icons.thermostat_rounded,
            label: 'Percepita',
            value:
                '${weather.feelsLike?.round() ?? weather.temperature.round()}°',
          ),
        ),
      ],
    );
  }
}

/// Single metric card.
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Hourly forecast card.
class _HourlyForecastCard extends StatelessWidget {
  const _HourlyForecastCard({required this.forecast});

  final dynamic forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${forecast.timestamp.hour}:00',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Icon(
              _weatherIcon(forecast.icon),
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              '${forecast.temperature.round()}°',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 12,
                  color: theme.colorScheme.primary.withAlpha(180),
                ),
                const SizedBox(width: 2),
                Text(
                  '${forecast.precipitationProbability}%',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _weatherIcon(String iconCode) {
    if (iconCode.contains('01')) return Icons.wb_sunny_rounded;
    if (iconCode.contains('02')) return Icons.cloud_queue_rounded;
    if (iconCode.contains('03') || iconCode.contains('04')) {
      return Icons.cloud_rounded;
    }
    if (iconCode.contains('09') || iconCode.contains('10')) {
      return Icons.grain_rounded;
    }
    if (iconCode.contains('11')) return Icons.flash_on_rounded;
    if (iconCode.contains('13')) return Icons.ac_unit_rounded;
    if (iconCode.contains('50')) return Icons.blur_on_rounded;
    return Icons.cloud_rounded;
  }
}

/// Daily forecast tile.
class _DailyForecastTile extends StatelessWidget {
  const _DailyForecastTile({required this.forecast});

  final dynamic forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '${weekdays[forecast.timestamp.weekday - 1]} ${forecast.timestamp.hour}:00',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Icon(
            _weatherIcon(forecast.icon),
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              forecast.description,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.water_drop,
                size: 14,
                color: theme.colorScheme.primary.withAlpha(180),
              ),
              const SizedBox(width: 2),
              Text(
                '${forecast.precipitationProbability}%',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${forecast.temperature.round()}°',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _weatherIcon(String iconCode) {
    if (iconCode.contains('01')) return Icons.wb_sunny_rounded;
    if (iconCode.contains('02')) return Icons.cloud_queue_rounded;
    if (iconCode.contains('03') || iconCode.contains('04')) {
      return Icons.cloud_rounded;
    }
    if (iconCode.contains('09') || iconCode.contains('10')) {
      return Icons.grain_rounded;
    }
    if (iconCode.contains('11')) return Icons.flash_on_rounded;
    if (iconCode.contains('13')) return Icons.ac_unit_rounded;
    if (iconCode.contains('50')) return Icons.blur_on_rounded;
    return Icons.cloud_rounded;
  }
}
