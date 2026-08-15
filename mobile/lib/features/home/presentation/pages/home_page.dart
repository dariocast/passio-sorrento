/// Home page widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/components.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_utils.dart';
import '../../domain/entities/confraternity.dart';
import '../../domain/repositories/home_repository.dart';
import '../cubit/home_cubit.dart';

/// Main home page of the app.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeCubit(repository: context.read<HomeRepository>())..loadData(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMunicipality;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Settimana Santa',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),
        ],
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            switch (state.status) {
              case HomeStatus.initial:
              case HomeStatus.loading:
                return _buildLoadingState();
              case HomeStatus.failure:
                return _buildErrorState(context, state);
              case HomeStatus.success:
                if (state.confraternities.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildSuccessState(context, state);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const LoadingState(useSkeleton: true, skeletonItemCount: 6);
  }

  Widget _buildErrorState(BuildContext context, HomeState state) {
    return ErrorState(
      title: 'Errore nel caricamento',
      message: state.errorMessage ?? 'Errore sconosciuto',
      onRetry: () => context.read<HomeCubit>().refresh(),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.church_outlined,
      title: 'Nessuna confraternita',
      message: 'Non sono state trovate confraternite.',
    );
  }

  Widget _buildSuccessState(BuildContext context, HomeState state) {
    final theme = Theme.of(context);

    // Check if there are any live processions
    final hasLiveProcessions = state.liveProcessions.isNotEmpty;

    // Filter confraternities based on search and municipality
    final query = _searchController.text.trim().toLowerCase();
    final filteredConfraternities = state.confraternities.where((c) {
      final matchesSearch = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.municipality.toLowerCase().contains(query);
      final matchesMunicipality = _selectedMunicipality == null ||
          c.municipality == _selectedMunicipality;
      return matchesSearch && matchesMunicipality;
    }).toList();

    // Group filtered confraternities by municipality
    final groupedByMunicipality = _groupByMunicipality(filteredConfraternities);
    final municipalities = groupedByMunicipality.keys.toList()..sort();

    // Distinct list of all available municipalities
    final allMunicipalities = state.confraternities
        .map((c) => c.municipality)
        .toSet()
        .toList()
      ..sort();

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().refresh(),
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Live Now Section
          if (hasLiveProcessions && query.isEmpty && _selectedMunicipality == null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const LiveDot(size: 10),
                    const SizedBox(width: 8),
                    Text(
                      'In Corso Ora',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: state.liveProcessions.length,
                  itemBuilder: (context, index) {
                    final procession = state.liveProcessions[index];
                    final confraternity = state.confraternities
                        .where((c) => c.id == procession.confraternityId)
                        .firstOrNull;

                    if (confraternity == null) return const SizedBox.shrink();

                    return _LiveProcessionCard(
                      confraternityId: confraternity.id,
                      name: confraternity.name,
                      municipality: confraternity.municipality,
                      color: confraternity.color,
                      processionName: procession.day,
                      onTap: () {
                        context.go(
                          AppRoutes.tracking,
                          extra: TrackingPageArgs(
                            confraternityId: confraternity.id,
                            confraternityName: confraternity.name,
                            confraternityColor: confraternity.color,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          ],

          // Search & Filter header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cerca confraternita o comune...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  // Municipality Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Tutti i comuni'),
                          selected: _selectedMunicipality == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedMunicipality = null);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ...allMunicipalities.map((m) {
                          final isSelected = _selectedMunicipality == m;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(m),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedMunicipality = selected ? m : null;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (filteredConfraternities.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Nessun risultato',
                message: 'Nessuna confraternita corrisponde ai criteri di ricerca.',
              ),
            ),

          // Grouped Confraternities by Municipality
          for (final municipality in municipalities) ...[
            // Section Header
            SliverToBoxAdapter(
              child: MunicipalitySection(
                municipality: municipality,
                count: groupedByMunicipality[municipality]!.length,
              ),
            ),

            // Confraternities in this municipality
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final confraternity =
                      groupedByMunicipality[municipality]![index];
                  final isLive = state.liveProcessions.any(
                    (p) => p.confraternityId == confraternity.id,
                  );

                  return _SwipeableConfraternityItem(
                    confraternity: confraternity,
                    isLive: isLive,
                    state: state,
                  );
                }, childCount: groupedByMunicipality[municipality]!.length),
              ),
            ),
          ],

          // Bottom padding for navigation bar
          const SliverToBoxAdapter(
            child: SizedBox(
              height: AppSpacing.xxl + kBottomNavigationBarHeight,
            ),
          ),
        ],
      ),
    );
  }

  /// Groups confraternities by municipality.
  Map<String, List<Confraternity>> _groupByMunicipality(
    List<Confraternity> confraternities,
  ) {
    final Map<String, List<Confraternity>> grouped = {};
    for (final confraternity in confraternities) {
      grouped.putIfAbsent(confraternity.municipality, () => []);
      grouped[confraternity.municipality]!.add(confraternity);
    }
    return grouped;
  }
}

/// Swipeable confraternity item with Hero animation.
class _SwipeableConfraternityItem extends StatelessWidget {
  const _SwipeableConfraternityItem({
    required this.confraternity,
    required this.isLive,
    required this.state,
  });

  final Confraternity confraternity;
  final bool isLive;
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key('confraternity_${confraternity.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Show info dialog instead of dismissing
        _showInfoDialog(context);
        return false; // Don't dismiss
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 4),
            Text(
              'Info',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
      child: _HeroConfraternityItem(
        confraternity: confraternity,
        isLive: isLive,
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final theme = Theme.of(context);
    final confraternityColor = ColorUtils.parseHex(confraternity.color);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Icon
            Hero(
              tag: 'confraternity_icon_${confraternity.id}',
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: confraternityColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: confraternityColor.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.church_rounded,
                  color: confraternityColor,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Name
            Text(
              confraternity.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Municipality
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  confraternity.municipality,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Actions
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Mappa',
                    icon: Icons.map_outlined,
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(
                        AppRoutes.tracking,
                        extra: TrackingPageArgs(
                          confraternityId: confraternity.id,
                          confraternityName: confraternity.name,
                          confraternityColor: confraternity.color,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: 'Dettagli',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                      context.goToConfraternity(
                        ConfraternityDetailArgs(
                          confraternityId: confraternity.id,
                          confraternityName: confraternity.name,
                          confraternityColor: confraternity.color,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

/// Confraternity list item with Hero animation support.
class _HeroConfraternityItem extends StatelessWidget {
  const _HeroConfraternityItem({
    required this.confraternity,
    required this.isLive,
  });

  final Confraternity confraternity;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confraternityColor = ColorUtils.parseHex(confraternity.color);

    return AppCard(
      accentColor: confraternityColor,
      accentPosition: AccentPosition.left,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () {
        context.goToConfraternity(
          ConfraternityDetailArgs(
            confraternityId: confraternity.id,
            confraternityName: confraternity.name,
            confraternityColor: confraternity.color,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Hero-wrapped color indicator
            Hero(
              tag: 'confraternity_icon_${confraternity.id}',
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: confraternityColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: confraternityColor.withAlpha(100),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.church_rounded,
                    color: confraternityColor,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with live badge
                  Row(
                    children: [
                      Flexible(
                        child: Hero(
                          tag: 'confraternity_name_${confraternity.id}',
                          flightShuttleBuilder:
                              (
                                flightContext,
                                animation,
                                flightDirection,
                                fromHeroContext,
                                toHeroContext,
                              ) {
                                return Material(
                                  color: Colors.transparent,
                                  child: toHeroContext.widget,
                                );
                              },
                          child: Text(
                            confraternity.name,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 8),
                        const LiveBadge(size: LiveBadgeSize.small),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Municipality is shown in section header, so show color hint
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: confraternityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Scorri per info rapide',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withAlpha(
                            150,
                          ),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            AnimatedChevron(color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Card for live processions in horizontal scroll.
class _LiveProcessionCard extends StatelessWidget {
  const _LiveProcessionCard({
    required this.confraternityId,
    required this.name,
    required this.municipality,
    required this.color,
    required this.onTap,
    this.processionName,
  });

  final String confraternityId;
  final String name;
  final String municipality;
  final String color;
  final String? processionName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confraternityColor = ColorUtils.parseHex(color);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: GradientHeaderCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [confraternityColor, confraternityColor.withAlpha(200)],
        ),
        headerPadding: const EdgeInsets.all(AppSpacing.md),
        bodyPadding: const EdgeInsets.all(AppSpacing.md),
        header: Row(
          children: [
            Hero(
              tag: 'confraternity_icon_$confraternityId',
              child: const Icon(Icons.church_rounded, size: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const LiveBadge(size: LiveBadgeSize.small),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(municipality, style: theme.textTheme.bodySmall),
              ],
            ),
            if (processionName != null) ...[
              const SizedBox(height: 4),
              Text(
                processionName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: confraternityColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
