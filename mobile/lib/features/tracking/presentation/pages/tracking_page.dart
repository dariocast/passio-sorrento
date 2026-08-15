/// Tracking page with live map.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/components/components.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_utils.dart';
import '../../domain/entities/tracking_data.dart';
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
                  state.filteredTrackingData.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _fitBounds(
                    state.filteredTrackingData.map((t) => t.position).toList(),
                  );
                });
              }
            },
            builder: (context, state) {
              final displayedData = state.filteredTrackingData;

              // Find selected tracking if any
              TrackingData? selectedTracking;
              if (state.selectedProcessionId != null) {
                selectedTracking = displayedData
                    .where((t) => t.processionId == state.selectedProcessionId)
                    .firstOrNull;
              }
              final trailColor = selectedTracking != null
                  ? ColorUtils.parseHex(selectedTracking.color)
                  : theme.colorScheme.primary;

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
                  // Dynamic tile layer (OSM / Light / Dark)
                  TileLayer(
                    urlTemplate: state.mapStyle.urlTemplate,
                    userAgentPackageName: 'xyz.dariocast.holyweek',
                  ),

                  // Procession historical trail / polyline
                  if (state.trailPoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.trailPoints,
                          color: trailColor.withAlpha(220),
                          strokeWidth: 5.0,
                          borderColor: Colors.white,
                          borderStrokeWidth: 1.5,
                        ),
                      ],
                    ),

                  // Markers for live processions
                  MarkerLayer(
                    markers: displayedData.map((tracking) {
                      final isSelected =
                          state.selectedProcessionId == tracking.processionId;
                      return Marker(
                        point: tracking.position,
                        width: 65,
                        height: 95,
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
                                      '${state.filteredTrackingData.length} in corso',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    if (state.filterMunicipality != null) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${state.filterMunicipality})',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Filter button
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
                          'Caricamento posizioni GPS...',
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
                  state.filteredTrackingData.isEmpty) {
                return Positioned(
                  bottom: AppSpacing.lg,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: StatusCard(
                    icon: Icons.location_off_rounded,
                    title: 'Nessuna processione attiva',
                    subtitle: state.filterMunicipality != null
                        ? 'Nessun corteo per ${state.filterMunicipality}'
                        : 'I cortei appariranno qui quando saranno in corso',
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
                trailCount: state.trailPoints.length,
                onClose: () =>
                    context.read<TrackingCubit>().selectProcession(null),
              );
            },
          ),
        ],
      ),

      // Map control actions FAB
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Map Style Toggle Button
          FloatingActionButton.small(
            heroTag: 'map_style',
            tooltip: 'Stile Mappa',
            onPressed: () => _showMapStyleSheet(context),
            child: const Icon(Icons.layers_rounded),
          ),
          const SizedBox(height: 8),

          // Zoom in
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () {
              final zoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, zoom + 1);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),

          // Zoom out
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () {
              final zoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, zoom - 1);
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),

          // Fit all markers
          BlocBuilder<TrackingCubit, TrackingState>(
            builder: (context, state) {
              if (state.filteredTrackingData.isEmpty) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton(
                heroTag: 'fit_all',
                onPressed: () {
                  _fitBounds(
                    state.filteredTrackingData.map((t) => t.position).toList(),
                  );
                },
                tooltip: 'Inquadra tutte',
                child: const Icon(Icons.fit_screen_rounded),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showMapStyleSheet(BuildContext context) {
    final cubit = context.read<TrackingCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stile Mappa',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final style in MapTileStyle.values)
                  ListTile(
                    title: Text(style.label),
                    trailing: cubit.state.mapStyle == style
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      cubit.setMapStyle(style);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    final cubit = context.read<TrackingCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => _FilterSheet(cubit: cubit),
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
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                name!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Marker Bubble
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
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.18,
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
          scale: widget.isSelected ? 1.25 : _pulseAnimation.value,
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
                  color: widget.color.withAlpha(widget.isSelected ? 180 : 100),
                  blurRadius: widget.isSelected ? 16 : 8,
                  spreadRadius: widget.isSelected ? 4 : 1,
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
  const _ProcessionBottomSheet({
    required this.tracking,
    required this.trailCount,
    required this.onClose,
  });

  final TrackingData tracking;
  final int trailCount;
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
              color: Colors.black.withAlpha(50),
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
                              trailCount > 1
                                  ? 'In corso — $trailCount posizioni tracciate'
                                  : 'In corso ora',
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
            // Actions
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Dettagli Confraternita',
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

/// Filter bottom sheet with municipality chips and search.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.cubit});

  final TrackingCubit cubit;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.cubit.state.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.cubit.state;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtra Processioni',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.filterMunicipality != null || state.searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      widget.cubit.setMunicipalityFilter(null);
                      widget.cubit.setSearchQuery('');
                      _searchController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Azzera'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Search box
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca per nome...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          widget.cubit.setSearchQuery('');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) {
                widget.cubit.setSearchQuery(value);
                setState(() {});
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Municipalities
            Text(
              'Comune',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              children: AppConstants.municipalities.map((municipality) {
                final isSelected = state.filterMunicipality == municipality;
                return ChoiceChip(
                  label: Text(municipality),
                  selected: isSelected,
                  onSelected: (selected) {
                    widget.cubit.setMunicipalityFilter(
                      selected ? municipality : null,
                    );
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
