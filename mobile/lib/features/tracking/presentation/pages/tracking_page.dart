/// Tracking page with live map.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/components/components.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_utils.dart';
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
    final theme = Theme.of(context);
    final title = widget.args?.confraternityName != null
        ? widget.args!.confraternityName!
        : 'Tracciamento Live';

    final confraternityColor = widget.args?.confraternityColor != null
        ? ColorUtils.parseHex(widget.args!.confraternityColor!)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          BlocConsumer<TrackingCubit, TrackingState>(
            listener: (context, state) {
              // Auto-zoom to fit markers when data loads
              if (state.status == TrackingStatus.success &&
                  state.trackingData.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _fitBounds(
                    state.trackingData.map((t) => t.position).toList(),
                  );
                });
              }
            },
            builder: (context, state) {
              return FlutterMap(
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
                      final isSelected =
                          state.selectedProcessionId == tracking.processionId;
                      return Marker(
                        point: tracking.position,
                        width: 60,
                        height: 90,
                        child: _ProcessionMarker(
                          color: ColorUtils.parseHex(tracking.color),
                          name: tracking.name,
                          isSelected: isSelected,
                          onTap: () => context
                              .read<TrackingCubit>()
                              .selectProcession(tracking.processionId),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),

          // App Bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withAlpha(200),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.7, 1],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      // Back button
                      FilledIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.pop(),
                        backgroundColor: theme.colorScheme.surface,
                        iconColor: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Title and active count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            BlocBuilder<TrackingCubit, TrackingState>(
                              builder: (context, state) {
                                if (state.trackingData.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Row(
                                  children: [
                                    const LiveDot(size: 8),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${state.trackingData.length} processioni attive',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Filter button (if showing all)
                      if (widget.args?.confraternityId == null)
                        FilledIconButton(
                          icon: Icons.filter_list_rounded,
                          onPressed: () => _showFilterSheet(context),
                          backgroundColor:
                              confraternityColor ??
                              theme.colorScheme.primaryContainer,
                          iconColor:
                              confraternityColor?.contrastColor ??
                              theme.colorScheme.onPrimaryContainer,
                          tooltip: 'Filtra',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          BlocBuilder<TrackingCubit, TrackingState>(
            builder: (context, state) {
              if (state.status == TrackingStatus.loading) {
                return Positioned(
                  top: 100,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Caricamento posizioni...',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Error message
          BlocBuilder<TrackingCubit, TrackingState>(
            builder: (context, state) {
              if (state.status == TrackingStatus.failure) {
                return Positioned(
                  bottom: AppSpacing.lg,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: ErrorBanner(
                    message: state.errorMessage ?? 'Errore di connessione',
                    onRetry: () => context.read<TrackingCubit>().loadData(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // No live processions message
          BlocBuilder<TrackingCubit, TrackingState>(
            builder: (context, state) {
              if (state.status == TrackingStatus.success &&
                  state.trackingData.isEmpty) {
                return Positioned(
                  bottom: AppSpacing.lg,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: StatusCard(
                    icon: Icons.location_off_rounded,
                    title: 'Nessuna processione attiva',
                    subtitle:
                        'Le processioni appariranno qui quando inizieranno',
                    status: CardStatus.info,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Selected procession bottom sheet
          BlocBuilder<TrackingCubit, TrackingState>(
            builder: (context, state) {
              if (state.selectedProcessionId == null) {
                return const SizedBox.shrink();
              }

              final tracking = state.trackingData
                  .where((t) => t.processionId == state.selectedProcessionId)
                  .firstOrNull;

              if (tracking == null) return const SizedBox.shrink();

              return _ProcessionBottomSheet(
                tracking: tracking,
                onClose: () =>
                    context.read<TrackingCubit>().selectProcession(null),
              );
            },
          ),
        ],
      ),

      // Zoom controls FAB
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () {
              final zoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, zoom + 1);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () {
              final zoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, zoom - 1);
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          BlocBuilder<TrackingCubit, TrackingState>(
            builder: (context, state) {
              if (state.trackingData.isEmpty) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton(
                heroTag: 'fit_all',
                onPressed: () {
                  _fitBounds(
                    state.trackingData.map((t) => t.position).toList(),
                  );
                },
                tooltip: 'Mostra tutte',
                child: const Icon(Icons.fit_screen_rounded),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _FilterSheet(),
    );
  }
}

/// Custom animated marker for processions.
class _ProcessionMarker extends StatelessWidget {
  const _ProcessionMarker({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.name,
  });

  final Color color;
  final String? name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label (shown when selected)
          if (isSelected && name != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                name!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Marker
          _AnimatedMarkerBubble(color: color, isSelected: isSelected),
        ],
      ),
    );
  }
}

class _AnimatedMarkerBubble extends StatefulWidget {
  const _AnimatedMarkerBubble({required this.color, required this.isSelected});

  final Color color;
  final bool isSelected;

  @override
  State<_AnimatedMarkerBubble> createState() => _AnimatedMarkerBubbleState();
}

class _AnimatedMarkerBubbleState extends State<_AnimatedMarkerBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isSelected ? 1.2 : _pulseAnimation.value,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: widget.isSelected ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withAlpha(widget.isSelected ? 150 : 80),
                  blurRadius: widget.isSelected ? 16 : 8,
                  spreadRadius: widget.isSelected ? 4 : 0,
                ),
              ],
            ),
            child: Icon(
              Icons.church_rounded,
              color: widget.color.contrastColor,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

/// Bottom sheet for selected procession details.
class _ProcessionBottomSheet extends StatelessWidget {
  const _ProcessionBottomSheet({required this.tracking, required this.onClose});

  final dynamic tracking;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ColorUtils.parseHex(tracking.color);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with color
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.church_rounded,
                      color: color.contrastColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tracking.name ?? 'Processione',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const LiveDot(size: 6),
                            const SizedBox(width: 4),
                            Text(
                              'In corso ora',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Dettagli',
                      icon: Icons.info_outline_rounded,
                      onPressed: () {
                        context.goToConfraternity(
                          ConfraternityDetailArgs(
                            confraternityId: tracking.confraternityId,
                            confraternityName: tracking.name ?? 'Processione',
                            confraternityColor: tracking.color,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter bottom sheet placeholder.
class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtra processioni', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          const EmptyState(
            icon: Icons.filter_list_off_rounded,
            title: 'Filtri in arrivo',
            message: 'Questa funzionalità sarà disponibile a breve.',
          ),
        ],
      ),
    );
  }
}
