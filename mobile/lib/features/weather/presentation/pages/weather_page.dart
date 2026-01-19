/// Weather page widget.
library;

import 'dart:math' as math;
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
  late final PageController _pageController;

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
    _pageController = PageController(
      initialPage: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
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
      child: _WeatherPageContent(
        tabController: _tabController,
        pageController: _pageController,
      ),
    );
  }
}

class _WeatherPageContent extends StatelessWidget {
  const _WeatherPageContent({
    required this.tabController,
    required this.pageController,
  });

  final TabController tabController;
  final PageController pageController;

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
                    pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
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

                // Swipeable PageView for municipalities
                return PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    tabController.animateTo(index);
                    context.read<WeatherCubit>().selectMunicipality(
                      AppConstants.municipalities[index],
                    );
                  },
                  itemCount: AppConstants.municipalities.length,
                  itemBuilder: (context, index) {
                    return _buildWeatherContent(context, state, weather);
                  },
                );
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

    // Calculate procession score
    final processionScore = _calculateProcessionScore(weather);

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

            // Procession-friendly score
            _ProcessionScoreCard(score: processionScore, weather: weather),
            const SizedBox(height: AppSpacing.md),

            // Weather warnings if any
            if (_hasWeatherWarnings(weather))
              _WeatherWarningsCard(weather: weather),
            if (_hasWeatherWarnings(weather))
              const SizedBox(height: AppSpacing.md),

            // Best time recommendation
            _BestTimeCard(forecast: state.forecast),
            const SizedBox(height: AppSpacing.lg),

            // Weather metrics grid
            _WeatherMetricsGrid(weather: weather),
            const SizedBox(height: AppSpacing.lg),

            // Wind visualization
            _WindVisualization(weather: weather),
            const SizedBox(height: AppSpacing.lg),

            // Precipitation probability chart
            if (state.forecast.isNotEmpty) ...[
              Text(
                'Probabilità Pioggia',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PrecipitationChart(forecast: state.forecast.take(12).toList()),
              const SizedBox(height: AppSpacing.lg),
            ],

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

            const SizedBox(height: AppSpacing.xxl + kBottomNavigationBarHeight),
          ],
        ),
      ),
    );
  }

  /// Calculate a score (0-100) for how good the weather is for processions.
  int _calculateProcessionScore(dynamic weather) {
    int score = 100;

    // Deduct for rain probability
    final rainProbability = weather.precipitationProbability as int;
    score -= (rainProbability * 0.5).round();

    // Deduct for extreme temperatures
    final temp = weather.temperature as double;
    if (temp < 10) score -= ((10 - temp) * 3).round();
    if (temp > 30) score -= ((temp - 30) * 3).round();

    // Deduct for high wind
    final wind = weather.windSpeed as double;
    if (wind > 5) score -= ((wind - 5) * 5).round();

    return score.clamp(0, 100);
  }

  bool _hasWeatherWarnings(dynamic weather) {
    return weather.precipitationProbability > 60 ||
        weather.windSpeed > 10 ||
        weather.temperature < 5 ||
        weather.temperature > 35;
  }
}

/// Current weather display card with animated icon.
class _CurrentWeatherCard extends StatefulWidget {
  const _CurrentWeatherCard({
    required this.weather,
    required this.municipalityColor,
  });

  final dynamic weather;
  final Color municipalityColor;

  @override
  State<_CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<_CurrentWeatherCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine if temperature is trending up or down (mock - would need historical data)
    final tempTrend = widget.weather.temperature > 20 ? 1 : -1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.municipalityColor,
            widget.municipalityColor.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: widget.municipalityColor.withAlpha(80),
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
            widget.weather.municipality,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Temperature and animated icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated weather icon
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Icon(
                        _weatherIcon(widget.weather.icon),
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Temperature with trend
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.weather.temperature.round()}°',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _TrendIndicator(trend: tempTrend),
                    ],
                  ),
                  Text(
                    widget.weather.description,
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

/// Temperature trend indicator arrow.
class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({required this.trend});

  final int trend; // 1 = up, -1 = down, 0 = stable

  @override
  Widget build(BuildContext context) {
    if (trend == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        trend > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

/// Procession-friendly score card.
class _ProcessionScoreCard extends StatelessWidget {
  const _ProcessionScoreCard({required this.score, required this.weather});

  final int score;
  final dynamic weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color scoreColor;
    String scoreLabel;
    IconData scoreIcon;

    if (score >= 80) {
      scoreColor = AppColors.success;
      scoreLabel = 'Ottimo per processioni';
      scoreIcon = Icons.check_circle_rounded;
    } else if (score >= 60) {
      scoreColor = AppColors.warning;
      scoreLabel = 'Buone condizioni';
      scoreIcon = Icons.info_rounded;
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreLabel = 'Condizioni discrete';
      scoreIcon = Icons.warning_rounded;
    } else {
      scoreColor = AppColors.error;
      scoreLabel = 'Condizioni avverse';
      scoreIcon = Icons.dangerous_rounded;
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scoreColor, width: 4),
              color: scoreColor.withAlpha(30),
            ),
            child: Center(
              child: Text(
                '$score',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(scoreIcon, size: 20, color: scoreColor),
                    const SizedBox(width: 6),
                    Text(
                      'Meteo Processioni',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  scoreLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Weather warnings card.
class _WeatherWarningsCard extends StatelessWidget {
  const _WeatherWarningsCard({required this.weather});

  final dynamic weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warnings = <_WarningItem>[];

    if (weather.precipitationProbability > 60) {
      warnings.add(
        _WarningItem(
          icon: Icons.water_drop_rounded,
          label:
              'Alta probabilità pioggia (${weather.precipitationProbability}%)',
          severity: weather.precipitationProbability > 80 ? 2 : 1,
        ),
      );
    }

    if (weather.windSpeed > 10) {
      warnings.add(
        _WarningItem(
          icon: Icons.air_rounded,
          label: 'Vento forte (${weather.windSpeed.round()} m/s)',
          severity: weather.windSpeed > 15 ? 2 : 1,
        ),
      );
    }

    if (weather.temperature < 5) {
      warnings.add(
        _WarningItem(
          icon: Icons.ac_unit_rounded,
          label: 'Temperatura bassa (${weather.temperature.round()}°C)',
          severity: weather.temperature < 0 ? 2 : 1,
        ),
      );
    }

    if (weather.temperature > 35) {
      warnings.add(
        _WarningItem(
          icon: Icons.local_fire_department_rounded,
          label: 'Temperatura elevata (${weather.temperature.round()}°C)',
          severity: weather.temperature > 38 ? 2 : 1,
        ),
      );
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return StatusCard(
      icon: Icons.warning_amber_rounded,
      title: 'Avvisi Meteo',
      subtitle:
          '${warnings.length} avvis${warnings.length == 1 ? 'o' : 'i'} attiv${warnings.length == 1 ? 'o' : 'i'}',
      status: CardStatus.warning,
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: warnings
            .map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      w.icon,
                      size: 16,
                      color: w.severity > 1
                          ? AppColors.error
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(w.label, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _WarningItem {
  const _WarningItem({
    required this.icon,
    required this.label,
    required this.severity,
  });

  final IconData icon;
  final String label;
  final int severity; // 1 = warning, 2 = critical
}

/// Best time for procession recommendation.
class _BestTimeCard extends StatelessWidget {
  const _BestTimeCard({required this.forecast});

  final List<dynamic> forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find the best time slot (lowest precipitation + good temp)
    if (forecast.isEmpty) return const SizedBox.shrink();

    dynamic bestSlot = forecast.first;
    int bestScore = _getSlotScore(forecast.first);

    for (final slot in forecast.take(12)) {
      final score = _getSlotScore(slot);
      if (score > bestScore) {
        bestScore = score;
        bestSlot = slot;
      }
    }

    final bestHour = bestSlot.timestamp as DateTime;
    final timeString = '${bestHour.hour.toString().padLeft(2, '0')}:00';
    final isToday = bestHour.day == DateTime.now().day;

    return AppCard(
      accentColor: AppColors.success,
      accentPosition: AccentPosition.left,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(30),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.schedule_rounded, color: AppColors.success),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orario consigliato',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${isToday ? 'Oggi' : 'Domani'} alle $timeString',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${bestSlot.temperature.round()}°',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.water_drop, size: 12, color: Colors.blue),
                  const SizedBox(width: 2),
                  Text(
                    '${bestSlot.precipitationProbability}%',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getSlotScore(dynamic slot) {
    int score = 100;
    score -= slot.precipitationProbability as int;

    final temp = slot.temperature as double;
    if (temp < 15 || temp > 28) score -= 10;

    return score;
  }
}

/// Wind direction and speed visualization.
class _WindVisualization extends StatelessWidget {
  const _WindVisualization({required this.weather});

  final dynamic weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windSpeed = weather.windSpeed as double;
    final windDeg = (weather.windDeg ?? 0) as int;

    String windDirection;
    if (windDeg >= 337.5 || windDeg < 22.5) {
      windDirection = 'N';
    } else if (windDeg < 67.5) {
      windDirection = 'NE';
    } else if (windDeg < 112.5) {
      windDirection = 'E';
    } else if (windDeg < 157.5) {
      windDirection = 'SE';
    } else if (windDeg < 202.5) {
      windDirection = 'S';
    } else if (windDeg < 247.5) {
      windDirection = 'SW';
    } else if (windDeg < 292.5) {
      windDirection = 'W';
    } else {
      windDirection = 'NW';
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Compass visualization
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compass circle
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(50),
                      width: 2,
                    ),
                  ),
                ),
                // Direction arrow
                Transform.rotate(
                  angle: windDeg * (math.pi / 180),
                  child: Icon(
                    Icons.navigation_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vento',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${windSpeed.round()} m/s',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        windDirection,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Wind strength indicator
          _WindStrengthIndicator(speed: windSpeed),
        ],
      ),
    );
  }
}

/// Wind strength visual indicator.
class _WindStrengthIndicator extends StatelessWidget {
  const _WindStrengthIndicator({required this.speed});

  final double speed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = _getWindLevel(speed);

    return Column(
      children: [
        Text(
          level.label,
          style: theme.textTheme.labelSmall?.copyWith(color: level.color),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(4, (index) {
            return Container(
              width: 6,
              height: 12 + (index * 4).toDouble(),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: index < level.bars
                    ? level.color
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }

  _WindLevel _getWindLevel(double speed) {
    if (speed < 3) {
      return const _WindLevel('Calmo', 1, AppColors.success);
    } else if (speed < 6) {
      return const _WindLevel('Leggero', 2, AppColors.success);
    } else if (speed < 10) {
      return const _WindLevel('Moderato', 3, AppColors.warning);
    } else {
      return const _WindLevel('Forte', 4, AppColors.error);
    }
  }
}

class _WindLevel {
  const _WindLevel(this.label, this.bars, this.color);

  final String label;
  final int bars;
  final Color color;
}

/// Precipitation probability chart.
class _PrecipitationChart extends StatelessWidget {
  const _PrecipitationChart({required this.forecast});

  final List<dynamic> forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Chart
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: forecast.map((f) {
                final prob = f.precipitationProbability as int;
                final height = (prob / 100) * 80;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$prob%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 8,
                            color: prob > 50
                                ? AppColors.warning
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: height.clamp(4, 80),
                          decoration: BoxDecoration(
                            color: prob > 50
                                ? AppColors.warning.withAlpha(200)
                                : theme.colorScheme.primary.withAlpha(150),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          // Hour labels
          Row(
            children: forecast.map((f) {
              final hour = (f.timestamp as DateTime).hour;
              return Expanded(
                child: Text(
                  '$hour',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                ),
              );
            }).toList(),
          ),
        ],
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
