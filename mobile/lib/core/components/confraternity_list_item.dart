/// Enhanced confraternity list item widget.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/color_utils.dart';
import 'live_badge.dart';
import 'app_card.dart';

/// Enhanced list item for displaying a confraternity.
class ConfraternityListItem extends StatelessWidget {
  const ConfraternityListItem({
    super.key,
    required this.name,
    required this.municipality,
    required this.color,
    required this.onTap,
    this.coatOfArms,
    this.isLive = false,
    this.liveLabel,
    this.subtitle,
    this.trailing,
    this.onLongPress,
  });

  /// Confraternity name.
  final String name;

  /// Municipality name.
  final String municipality;

  /// Hex color string of the confraternity.
  final String color;

  /// Coat of arms image path or URL.
  final String? coatOfArms;

  /// Tap callback.
  final VoidCallback onTap;

  /// Whether there's a live procession.
  final bool isLive;

  /// Custom label for live badge.
  final String? liveLabel;

  /// Optional subtitle (e.g., procession name).
  final String? subtitle;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Long press callback.
  final VoidCallback? onLongPress;

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final root = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$root$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confraternityColor = ColorUtils.parseHex(color);
    final imageUrl = _resolveImageUrl(coatOfArms);

    return AppCard(
      accentColor: confraternityColor,
      accentPosition: AccentPosition.left,
      onTap: onTap,
      onLongPress: onLongPress,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Color indicator / Stemma avatar
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: confraternityColor.withAlpha(30),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: confraternityColor.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Center(
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Icon(
                          Icons.church_rounded,
                          color: confraternityColor,
                          size: 22,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.church_rounded,
                          color: confraternityColor,
                          size: 22,
                        ),
                      )
                    : Icon(
                        Icons.church_rounded,
                        color: confraternityColor,
                        size: 22,
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
                        child: Text(
                          name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 8),
                        LiveBadge(
                          label: liveLabel ?? 'LIVE',
                          size: LiveBadgeSize.small,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Municipality
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        municipality,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // Optional subtitle
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
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
            ),

            // Trailing widget or chevron
            trailing ??
                AnimatedChevron(color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Animated chevron that hints at tap action.
class AnimatedChevron extends StatefulWidget {
  const AnimatedChevron({super.key, this.color, this.size = 24});

  final Color? color;
  final double size;

  @override
  State<AnimatedChevron> createState() => _AnimatedChevronState();
}

class _AnimatedChevronState extends State<AnimatedChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.repeat(reverse: true),
      onExit: (_) {
        _controller.reverse();
        _controller.stop();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: Icon(
              Icons.chevron_right_rounded,
              color: widget.color,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}

/// Compact confraternity chip for filters or selections.
class ConfraternityChip extends StatelessWidget {
  const ConfraternityChip({
    super.key,
    required this.name,
    required this.color,
    this.onTap,
    this.onDelete,
    this.selected = false,
  });

  final String name;
  final String color;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confraternityColor = ColorUtils.parseHex(color);

    return FilterChip(
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      onDeleted: onDelete,
      avatar: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: confraternityColor,
          shape: BoxShape.circle,
        ),
      ),
      label: Text(name),
      selectedColor: confraternityColor.withAlpha(50),
      checkmarkColor: confraternityColor,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? confraternityColor : null,
      ),
    );
  }
}

/// Section header for grouped lists.
class MunicipalitySection extends StatelessWidget {
  const MunicipalitySection({
    super.key,
    required this.municipality,
    required this.count,
    this.onTap,
  });

  final String municipality;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final municipalityColor = AppColors.getMunicipalityColor(municipality);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: municipalityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              municipality,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(count.toString(), style: theme.textTheme.labelSmall),
            ),
            if (onTap != null) ...[
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
