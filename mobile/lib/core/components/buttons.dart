/// Custom button variants.
library;

import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

/// Primary filled button with optional icon.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.size = ButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final config = size._config;

    Widget button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: config.horizontalPadding,
          vertical: config.verticalPadding,
        ),
        textStyle: TextStyle(
          fontSize: config.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: config.iconSize,
              height: config.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: config.iconSize),
                  SizedBox(width: config.iconSpacing),
                ],
                Text(label),
              ],
            ),
    );

    if (isExpanded) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

/// Secondary outlined button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.size = ButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final config = size._config;

    Widget button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: config.horizontalPadding,
          vertical: config.verticalPadding,
        ),
        textStyle: TextStyle(
          fontSize: config.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: config.iconSize,
              height: config.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: config.iconSize),
                  SizedBox(width: config.iconSpacing),
                ],
                Text(label),
              ],
            ),
    );

    if (isExpanded) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

/// Button styled with a confraternity's color.
class ConfraternityButton extends StatelessWidget {
  const ConfraternityButton({
    super.key,
    required this.label,
    required this.confraternityColor,
    required this.onPressed,
    this.icon,
    this.filled = true,
    this.size = ButtonSize.medium,
  });

  final String label;
  final String confraternityColor; // Hex color string
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.parseHex(confraternityColor);
    final textColor = color.contrastColor;
    final config = size._config;

    if (!filled) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: EdgeInsets.symmetric(
            horizontal: config.horizontalPadding,
            vertical: config.verticalPadding,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: config.iconSize),
              SizedBox(width: config.iconSpacing),
            ],
            Text(label),
          ],
        ),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: config.horizontalPadding,
          vertical: config.verticalPadding,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: config.iconSize),
            SizedBox(width: config.iconSpacing),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// Icon button with background.
class FilledIconButton extends StatelessWidget {
  const FilledIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = Material(
      color: backgroundColor ?? theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(size / 4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 4),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              size: size * 0.5,
              color: iconColor ?? theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// Quick action button (like the ones in home page grid).
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.colorScheme.primary).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: textColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Button size variants.
enum ButtonSize {
  small(_SmallConfig()),
  medium(_MediumConfig()),
  large(_LargeConfig());

  const ButtonSize(this._config);
  final _SizeConfig _config;
}

abstract class _SizeConfig {
  double get horizontalPadding;
  double get verticalPadding;
  double get fontSize;
  double get iconSize;
  double get iconSpacing;
}

class _SmallConfig implements _SizeConfig {
  const _SmallConfig();

  @override
  double get horizontalPadding => 12;
  @override
  double get verticalPadding => 6;
  @override
  double get fontSize => 12;
  @override
  double get iconSize => 16;
  @override
  double get iconSpacing => 4;
}

class _MediumConfig implements _SizeConfig {
  const _MediumConfig();

  @override
  double get horizontalPadding => 20;
  @override
  double get verticalPadding => 10;
  @override
  double get fontSize => 14;
  @override
  double get iconSize => 20;
  @override
  double get iconSpacing => 8;
}

class _LargeConfig implements _SizeConfig {
  const _LargeConfig();

  @override
  double get horizontalPadding => 28;
  @override
  double get verticalPadding => 14;
  @override
  double get fontSize => 16;
  @override
  double get iconSize => 24;
  @override
  double get iconSpacing => 10;
}
