/// Tracking page with live map.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../cubit/tracking_cubit.dart';

/// Page showing live tracking of processions on a map.
class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrackingCubit(
        repository: context.read<TrackingRepository>(),
      )..startWatching(),
      child: const _TrackingPageContent(),
    );
  }
}

class _TrackingPageContent extends StatelessWidget {
  const _TrackingPageContent();

  // Sorrento Peninsula center coordinates
  static const _sorrentoCenter = LatLng(40.6263, 14.3758);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracciamento Live'),
        actions: [
          BlocBuilder<TrackingCubit, TrackingState>(
            builder: (context, state) {
              if (state.trackingData.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Chip(
                  avatar: const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                  label: Text('${state.trackingData.length} attive'),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Map
              FlutterMap(
                options: MapOptions(
                  initialCenter: _sorrentoCenter,
                  initialZoom: 13,
                ),
                children: [
                  // OpenStreetMap tile layer
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'xyz.dariocast.holyweek',
                  ),

                  // Markers for live processions
                  MarkerLayer(
                    markers: state.trackingData.map((tracking) {
                      return Marker(
                        point: tracking.position,
                        width: 50,
                        height: 50,
                        child: _LiveMarker(
                          isSelected: state.selectedProcessionId == tracking.processionId,
                          onTap: () => context.read<TrackingCubit>().selectProcession(
                                tracking.processionId,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Loading overlay
              if (state.status == TrackingStatus.loading)
                const Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Caricamento...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Error message
              if (state.status == TrackingStatus.failure)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: Colors.red.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(state.errorMessage ?? 'Errore di connessione'),
                          ),
                          TextButton(
                            onPressed: () => context.read<TrackingCubit>().loadData(),
                            child: const Text('Riprova'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // No live processions message
              if (state.status == TrackingStatus.success && state.trackingData.isEmpty)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Nessuna processione attiva al momento'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Custom marker widget for live processions.
class _LiveMarker extends StatelessWidget {
  const _LiveMarker({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 50 : 40,
        height: isSelected ? 50 : 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.church,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
