import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/components.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_utils.dart';
import '../../domain/repositories/home_repository.dart';
import '../cubit/home_cubit.dart';

/// Page showing detailed information about a confraternity.
class ConfraternityDetailPage extends StatelessWidget {
  const ConfraternityDetailPage({super.key, required this.args});

  final ConfraternityDetailArgs args;

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final root = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$root$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.parseHex(args.confraternityColor);
    final contrastColor = color.contrastColor;

    return BlocProvider(
      create: (context) =>
          HomeCubit(repository: context.read<HomeRepository>())..loadData(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Hero header with confraternity color
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: color,
              foregroundColor: contrastColor,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  args.confraternityName,
                  style: TextStyle(
                    color: contrastColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.lighten(0.1),
                            color,
                            color.darken(0.1),
                          ],
                        ),
                      ),
                    ),
                    // Pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PatternPainter(
                          color: contrastColor.withAlpha(15),
                        ),
                      ),
                    ),
                    // Icon / Stemma with Hero animation
                    Center(
                      child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          final confraternity = state.confraternities
                              .where((c) => c.id == args.confraternityId)
                              .firstOrNull;
                          final imageUrl = _resolveImageUrl(confraternity?.coatOfArms);

                          return Hero(
                            tag: 'confraternity_icon_${args.confraternityId}',
                            child: Container(
                              width: 88,
                              height: 88,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: contrastColor.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) => Icon(
                                          Icons.church_rounded,
                                          size: 48,
                                          color: contrastColor.withAlpha(120),
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.church_rounded,
                                          size: 48,
                                          color: contrastColor.withAlpha(120),
                                        ),
                                      )
                                    : Icon(
                                        Icons.church_rounded,
                                        size: 48,
                                        color: contrastColor.withAlpha(120),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.status == HomeStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: LoadingState(),
                    );
                  }

                  final confraternity = state.confraternities
                      .where((c) => c.id == args.confraternityId)
                      .firstOrNull;

                  if (confraternity == null) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Confraternita non trovata',
                      ),
                    );
                  }

                  // Check if there's a live procession
                  final isLive = state.liveProcessions.any(
                    (p) => p.confraternityId == confraternity.id,
                  );

                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live banner if applicable
                        if (isLive)
                          StatusCard(
                            icon: Icons.sensors,
                            title: 'Processione in corso',
                            subtitle: 'Segui la processione in tempo reale',
                            status: CardStatus.success,
                            action: TextButton(
                              onPressed: () {
                                context.go(
                                  AppRoutes.tracking,
                                  extra: TrackingPageArgs(
                                    confraternityId: args.confraternityId,
                                    confraternityName: args.confraternityName,
                                    confraternityColor: args.confraternityColor,
                                  ),
                                );
                              },
                              child: const Text('Segui'),
                            ),
                          ),

                        if (isLive) const SizedBox(height: AppSpacing.md),

                        // Municipality card - clickable to weather
                        AppCard(
                          accentColor: ColorUtils.parseHex(
                            confraternity.color,
                          ).withAlpha(100),
                          accentPosition: AccentPosition.left,
                          onTap: () {
                            context.goToWeather(
                              municipality: confraternity.municipality,
                            );
                          },
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.location_city_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Comune',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      confraternity.municipality,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cloud_outlined,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // History section
                        Text(
                          'Storia',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            confraternity.history ??
                                'La storia di questa confraternita sarà disponibile a breve.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Actions section
                        Text(
                          'Azioni rapide',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Primary CTA
                        ConfraternityButton(
                          label: 'Vedi sulla mappa',
                          confraternityColor: args.confraternityColor,
                          icon: Icons.map_rounded,
                          onPressed: () {
                            context.go(
                              AppRoutes.tracking,
                              extra: TrackingPageArgs(
                                confraternityId: args.confraternityId,
                                confraternityName: args.confraternityName,
                                confraternityColor: args.confraternityColor,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Secondary CTA
                        SecondaryButton(
                          label: 'Meteo a ${confraternity.municipality}',
                          icon: Icons.cloud_outlined,
                          isExpanded: true,
                          onPressed: () {
                            context.goToWeather(
                              municipality: confraternity.municipality,
                            );
                          },
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for decorative pattern in header.
class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;

    // Draw diagonal lines
    for (var x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
