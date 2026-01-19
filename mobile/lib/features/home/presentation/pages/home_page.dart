/// Home page widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/components/components.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
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

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

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
                ),
              ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.cloud_outlined,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.weather);
                },
                tooltip: 'Meteo',
              ),
              IconButton(
                icon: Icon(
                  Icons.map_outlined,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.tracking);
                },
                tooltip: 'Tracciamento Live',
              ),
              const SizedBox(width: 8),
            ],
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

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().refresh(),
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Live Now Section
          if (hasLiveProcessions) ...[
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
                      'In Corso',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
                      name: confraternity.name,
                      municipality: confraternity.municipality,
                      color: confraternity.color,
                      processionName: procession.day,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.tracking,
                          arguments: TrackingPageArgs(
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

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.cloud_outlined,
                      label: 'Meteo',
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.weather),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.map_outlined,
                      label: 'Mappa',
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.tracking),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // All Confraternities Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'Tutte le Confraternite',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Confraternity List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final confraternity = state.confraternities[index];
                final isLive = state.liveProcessions.any(
                  (p) => p.confraternityId == confraternity.id,
                );

                return ConfraternityListItem(
                  name: confraternity.name,
                  municipality: confraternity.municipality,
                  color: confraternity.color,
                  isLive: isLive,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.confraternityDetail,
                      arguments: ConfraternityDetailArgs(
                        confraternityId: confraternity.id,
                        confraternityName: confraternity.name,
                        confraternityColor: confraternity.color,
                      ),
                    );
                  },
                );
              }, childCount: state.confraternities.length),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

/// Card for live processions in horizontal scroll.
class _LiveProcessionCard extends StatelessWidget {
  const _LiveProcessionCard({
    required this.name,
    required this.municipality,
    required this.color,
    required this.onTap,
    this.processionName,
  });

  final String name;
  final String municipality;
  final String color;
  final String? processionName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: GradientHeaderCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_parseColor(color), _parseColor(color).withAlpha(200)],
        ),
        headerPadding: const EdgeInsets.all(AppSpacing.md),
        bodyPadding: const EdgeInsets.all(AppSpacing.md),
        header: Row(
          children: [
            const Icon(Icons.church_rounded, size: 24),
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
                  color: _parseColor(color),
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

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
