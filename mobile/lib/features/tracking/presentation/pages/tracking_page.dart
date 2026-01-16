/// Tracking page with live map.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../cubit/tracking_cubit.dart';

/// Page showing live tracking of processions on a map.
class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key, this.args});

  final TrackingPageArgs? args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrackingCubit(
        repository: context.read<TrackingRepository>(),
        confraternityIdFilter: args?.confraternityId,
      )..startWatching(),
      child: _TrackingPageContent(args: args),
    );
  }
}

class _TrackingPageContent extends StatefulWidget {
  const _TrackingPageContent({this.args});

  final TrackingPageArgs? args;

  @override
  State<_TrackingPageContent> createState() => _TrackingPageContentState();
}

class _TrackingPageContentState extends State<_TrackingPageContent> {
  final MapController _mapController = MapController();

  // Sorrento Peninsula center coordinates
  static const _sorrentoCenter = LatLng(40.6263, 14.3758);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.args?.confraternityName != null
        ? 'Tracciamento ${widget.args!.confraternityName}'
        : 'Tracciamento Live';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          BlocBuilder<TrackingCubit, TrackingState>(
            builder: (context, state) {
              if (state.trackingData.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Chip(
                  avatar: const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 12,
                  ),
                  label: Text('${state.trackingData.length} attive'),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TrackingCubit, TrackingState>(
        listener: (context, state) {
          // Auto-zoom to fit markers when data loads
          if (state.status == TrackingStatus.success &&
              state.trackingData.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _fitBounds(state.trackingData.map((t) => t.position).toList());
            });
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _sorrentoCenter,
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onTap: (_, __) {
                    // Deselect when tapping map
                    context.read<TrackingCubit>().selectProcession(null);
                  },
                ),
                children: [
                  // OpenStreetMap tile layer
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'xyz.dariocast.holyweek',
                  ),

                  // Markers for live processions
                  MarkerLayer(
                    markers: state.trackingData.map((tracking) {
                      return Marker(
                        point: tracking.position,
                        width: 50,
                        height: 80, // Extra height for label
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Label (shown when selected)
                            if (state.selectedProcessionId ==
                                    tracking.processionId &&
                                tracking.name != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tracking.name!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            // Marker
                            _LiveMarker(
                              color: _parseColor(tracking.color),
                              isSelected:
                                  state.selectedProcessionId ==
                                  tracking.processionId,
                              onTap: () => context
                                  .read<TrackingCubit>()
                                  .selectProcession(tracking.processionId),
                            ),
                          ],
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
                            child: Text(
                              state.errorMessage ?? 'Errore di connessione',
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.read<TrackingCubit>().loadData(),
                            child: const Text('Riprova'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // No live processions message
              if (state.status == TrackingStatus.success &&
                  state.trackingData.isEmpty)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Nessuna processione attiva al momento',
                            ),
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

  /// Parses a hex color string to a Color.
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF5C1A1B); // Fallback color
    }
  }
}

/// Custom marker widget for live processions.
class _LiveMarker extends StatelessWidget {
  const _LiveMarker({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
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
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.church, color: Colors.white, size: 20),
      ),
    );
  }
}
