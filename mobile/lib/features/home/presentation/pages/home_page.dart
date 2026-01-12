/// Home page widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/home_repository.dart';
import '../cubit/home_cubit.dart';

/// Main home page of the app.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        repository: context.read<HomeRepository>(),
      )..loadData(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settimana Santa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed: () {
              // TODO: Navigate to weather page
            },
            tooltip: 'Meteo',
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // TODO: Navigate to tracking page
            },
            tooltip: 'Tracciamento Live',
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          switch (state.status) {
            case HomeStatus.initial:
            case HomeStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case HomeStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Errore nel caricamento',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(state.errorMessage ?? 'Errore sconosciuto'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<HomeCubit>().refresh(),
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              );
            case HomeStatus.success:
              if (state.confraternities.isEmpty) {
                return const Center(
                  child: Text('Nessuna confraternita trovata'),
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.confraternities.length,
                  itemBuilder: (context, index) {
                    final confraternity = state.confraternities[index];
                    final isLive = state.liveProcessions
                        .any((p) => p.confraternityId == confraternity.id);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: _parseColor(confraternity.color),
                              width: 4,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  confraternity.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              if (isLive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(confraternity.municipality),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to confraternity detail
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
