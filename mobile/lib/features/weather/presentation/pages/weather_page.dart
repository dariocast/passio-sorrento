/// Weather page widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meteo'),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: AppConstants.municipalities.map((m) => Tab(text: m)).toList(),
          onTap: (index) {
            context.read<WeatherCubit>().selectMunicipality(
              AppConstants.municipalities[index],
            );
          },
        ),
      ),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          switch (state.status) {
            case WeatherStatus.initial:
            case WeatherStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case WeatherStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Impossibile caricare il meteo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(state.errorMessage ?? ''),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<WeatherCubit>().loadWeather(
                        state.selectedMunicipality ??
                            AppConstants.municipalities.first,
                      ),
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              );

            case WeatherStatus.success:
              final weather = state.currentWeather;
              if (weather == null) {
                return const Center(child: Text('Nessun dato meteo'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Current weather card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              weather.municipality,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _weatherIcon(weather.icon),
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${weather.temperature.round()}°C',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weather.description,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Precipitation card (important for processions)
                    Card(
                      color: weather.precipitationProbability > 50
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                      child: ListTile(
                        leading: Icon(
                          Icons.water_drop,
                          color: weather.precipitationProbability > 50
                              ? Colors.orange
                              : Colors.green,
                        ),
                        title: const Text('Probabilità Pioggia'),
                        subtitle: Text(
                          weather.precipitationProbability > 50
                              ? 'Alta probabilità di pioggia'
                              : 'Bassa probabilità di pioggia',
                        ),
                        trailing: Text(
                          '${weather.precipitationProbability}%',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Forecast section
                    if (state.forecast.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Previsioni',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...state.forecast
                          .take(5)
                          .map(
                            (f) => Card(
                              child: ListTile(
                                leading: Icon(_weatherIcon(f.icon)),
                                title: Text(
                                  '${f.temperature.round()}°C - ${f.description}',
                                ),
                                subtitle: Text(_formatDateTime(f.timestamp)),
                                trailing: Text(
                                  '${f.precipitationProbability}%',
                                ),
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  IconData _weatherIcon(String iconCode) {
    if (iconCode.contains('01')) return Icons.wb_sunny;
    if (iconCode.contains('02')) return Icons.cloud_queue;
    if (iconCode.contains('03') || iconCode.contains('04')) return Icons.cloud;
    if (iconCode.contains('09') || iconCode.contains('10')) return Icons.grain;
    if (iconCode.contains('11')) return Icons.flash_on;
    if (iconCode.contains('13')) return Icons.ac_unit;
    if (iconCode.contains('50')) return Icons.blur_on;
    return Icons.cloud;
  }

  String _formatDateTime(DateTime dt) {
    final weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    return '${weekdays[dt.weekday - 1]} ${dt.hour}:00';
  }
}
