/// Enhanced card widget with multiple style options.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Enhanced card with border accents, gradients, and elevation options.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.accentColor,
    this.accentPosition = AccentPosition.left,
    this.gradient,
    this.elevation,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.clipBehavior = Clip.antiAlias,
    this.outlined = false,
    this.filled = false,
    this.fillColor,
  });

  /// The card content.
  final Widget child;

  /// An accent color bar to show on the card edge.
  final Color? accentColor;

  /// Position of the accent bar.
  final AccentPosition accentPosition;

  /// Optional gradient background.
  final Gradient? gradient;

  /// Card elevation. If null, uses theme default.
  final double? elevation;

  /// Internal padding.
  final EdgeInsetsGeometry? padding;

  /// Margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Border radius. If null, uses theme default.
  final BorderRadius? borderRadius;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Long press callback.
  final VoidCallback? onLongPress;

  /// Clip behavior for content.
  final Clip clipBehavior;

  /// Whether to show an outline instead of elevation.
  final bool outlined;

  /// Whether to fill the card with a background color.
  final bool filled;

  /// Fill color when filled is true.
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadius.lg);

    Widget cardContent = child;

    // Apply padding if specified
    if (padding != null) {
      cardContent = Padding(padding: padding!, child: cardContent);
    }

    // Apply accent bar
    if (accentColor != null) {
      cardContent = _AccentedContent(
        accentColor: accentColor!,
        position: accentPosition,
        child: cardContent,
      );
    }

    // Apply gradient background
    if (gradient != null) {
      cardContent = DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: cardContent,
      );
    }

    Widget card = Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: elevation ?? (outlined ? 0 : AppElevation.level0),
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveRadius,
        side: outlined
            ? BorderSide(color: theme.colorScheme.outlineVariant)
            : BorderSide.none,
      ),
      color: filled
          ? (fillColor ?? theme.colorScheme.surfaceContainerHighest)
          : theme.colorScheme.surface,
      child: cardContent,
    );

    // Apply ink well for tap effects
    if (onTap != null || onLongPress != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: effectiveRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Position of the accent bar on the card.
enum AccentPosition { left, right, top, bottom }

class _AccentedContent extends StatelessWidget {
  const _AccentedContent({
    required this.accentColor,
    required this.position,
    required this.child,
  });

  final Color accentColor;
  final AccentPosition position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const accentWidth = 4.0;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: position == AccentPosition.left
              ? BorderSide(color: accentColor, width: accentWidth)
              : BorderSide.none,
          right: position == AccentPosition.right
              ? BorderSide(color: accentColor, width: accentWidth)
              : BorderSide.none,
          top: position == AccentPosition.top
              ? BorderSide(color: accentColor, width: accentWidth)
              : BorderSide.none,
          bottom: position == AccentPosition.bottom
              ? BorderSide(color: accentColor, width: accentWidth)
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}

/// A card variant with a gradient header.
class GradientHeaderCard extends StatelessWidget {
  const GradientHeaderCard({
    super.key,
    required this.header,
    required this.body,
    this.gradient,
    this.headerPadding = const EdgeInsets.all(16),
    this.bodyPadding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget header;
  final Widget body;
  final Gradient? gradient;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry bodyPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: gradient ?? AppColors.primaryGradient,
            ),
            padding: headerPadding,
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: header,
              ),
            ),
          ),
          Padding(padding: bodyPadding, child: body),
        ],
      ),
    );
  }
}

/// A card that displays a status indicator.
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.status = CardStatus.info,
    this.action,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final CardStatus status;
  final Widget? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusConfig = status._config;

    return AppCard(
      filled: true,
      fillColor: statusConfig.backgroundColor(theme),
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusConfig.iconBackgroundColor(theme),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusConfig.iconColor(theme), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: statusConfig.textColor(theme),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusConfig.textColor(theme).withAlpha(180),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

enum CardStatus {
  info(_InfoStatusConfig()),
  success(_SuccessStatusConfig()),
  warning(_WarningStatusConfig()),
  error(_ErrorStatusConfig());

  const CardStatus(this._config);
  final _StatusConfig _config;
}

abstract class _StatusConfig {
  Color backgroundColor(ThemeData theme);
  Color iconColor(ThemeData theme);
  Color iconBackgroundColor(ThemeData theme);
  Color textColor(ThemeData theme);
}

class _InfoStatusConfig implements _StatusConfig {
  const _InfoStatusConfig();

  @override
  Color backgroundColor(ThemeData theme) =>
      theme.colorScheme.primaryContainer.withAlpha(50);
  @override
  Color iconColor(ThemeData theme) => theme.colorScheme.primary;
  @override
  Color iconBackgroundColor(ThemeData theme) =>
      theme.colorScheme.primary.withAlpha(30);
  @override
  Color textColor(ThemeData theme) => theme.colorScheme.onSurface;
}

class _SuccessStatusConfig implements _StatusConfig {
  const _SuccessStatusConfig();

  @override
  Color backgroundColor(ThemeData theme) => AppColors.successContainer;
  @override
  Color iconColor(ThemeData theme) => AppColors.success;
  @override
  Color iconBackgroundColor(ThemeData theme) => AppColors.success.withAlpha(30);
  @override
  Color textColor(ThemeData theme) => AppColors.onSuccessContainer;
}

class _WarningStatusConfig implements _StatusConfig {
  const _WarningStatusConfig();

  @override
  Color backgroundColor(ThemeData theme) => AppColors.warningContainer;
  @override
  Color iconColor(ThemeData theme) => AppColors.warning;
  @override
  Color iconBackgroundColor(ThemeData theme) => AppColors.warning.withAlpha(30);
  @override
  Color textColor(ThemeData theme) => AppColors.onWarningContainer;
}

class _ErrorStatusConfig implements _StatusConfig {
  const _ErrorStatusConfig();

  @override
  Color backgroundColor(ThemeData theme) => AppColors.errorContainer;
  @override
  Color iconColor(ThemeData theme) => AppColors.error;
  @override
  Color iconBackgroundColor(ThemeData theme) => AppColors.error.withAlpha(30);
  @override
  Color textColor(ThemeData theme) => AppColors.onErrorContainer;
}
