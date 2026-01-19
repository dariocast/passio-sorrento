/// Responsive utility functions and widgets.
library;

import 'package:flutter/material.dart';

/// Breakpoint definitions following Material Design 3 guidelines.
enum Breakpoint {
  /// Mobile: < 600dp
  compact(0, 599),

  /// Tablet: 600-839dp
  medium(600, 839),

  /// Desktop: >= 840dp
  expanded(840, 999999);

  const Breakpoint(this.minWidth, this.maxWidth);

  final int minWidth;
  final int maxWidth;

  /// Check if a width falls within this breakpoint.
  bool matches(double width) => width >= minWidth && width <= maxWidth;
}

/// Utility class for responsive design.
abstract final class ResponsiveUtils {
  /// Get the current breakpoint based on screen width.
  static Breakpoint getBreakpoint(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return Breakpoint.compact;
    if (width < 840) return Breakpoint.medium;
    return Breakpoint.expanded;
  }

  /// Check if the current screen is mobile size.
  static bool isMobile(BuildContext context) =>
      getBreakpoint(context) == Breakpoint.compact;

  /// Check if the current screen is tablet size.
  static bool isTablet(BuildContext context) =>
      getBreakpoint(context) == Breakpoint.medium;

  /// Check if the current screen is desktop size.
  static bool isDesktop(BuildContext context) =>
      getBreakpoint(context) == Breakpoint.expanded;

  /// Get the number of grid columns for the current breakpoint.
  static int getGridColumns(BuildContext context) {
    switch (getBreakpoint(context)) {
      case Breakpoint.compact:
        return 1;
      case Breakpoint.medium:
        return 2;
      case Breakpoint.expanded:
        return 3;
    }
  }

  /// Get horizontal padding for the current breakpoint.
  static double getHorizontalPadding(BuildContext context) {
    switch (getBreakpoint(context)) {
      case Breakpoint.compact:
        return 16;
      case Breakpoint.medium:
        return 24;
      case Breakpoint.expanded:
        return 32;
    }
  }

  /// Get the max content width for the current breakpoint.
  static double? getMaxContentWidth(BuildContext context) {
    switch (getBreakpoint(context)) {
      case Breakpoint.compact:
        return null; // Full width
      case Breakpoint.medium:
        return null; // Full width
      case Breakpoint.expanded:
        return 1200; // Max width for large screens
    }
  }
}

/// Widget that builds different layouts based on screen size.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  /// Builder for mobile/compact screens (required).
  final Widget Function(BuildContext context) compact;

  /// Builder for tablet/medium screens (falls back to compact).
  final Widget Function(BuildContext context)? medium;

  /// Builder for desktop/expanded screens (falls back to medium or compact).
  final Widget Function(BuildContext context)? expanded;

  @override
  Widget build(BuildContext context) {
    final breakpoint = ResponsiveUtils.getBreakpoint(context);

    switch (breakpoint) {
      case Breakpoint.compact:
        return compact(context);
      case Breakpoint.medium:
        return (medium ?? compact)(context);
      case Breakpoint.expanded:
        return (expanded ?? medium ?? compact)(context);
    }
  }
}

/// Widget that switches between a list and grid layout based on screen size.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(context);

    if (columns == 1) {
      return Column(
        children: children
            .map(
              (child) => Padding(
                padding: EdgeInsets.only(bottom: runSpacing),
                child: child,
              ),
            )
            .toList(),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        final itemWidth =
            (MediaQuery.sizeOf(context).width -
                (ResponsiveUtils.getHorizontalPadding(context) * 2) -
                (spacing * (columns - 1))) /
            columns;
        return SizedBox(width: itemWidth, child: child);
      }).toList(),
    );
  }
}

/// Container that constrains content width on large screens.
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.center = true,
  });

  final Widget child;
  final double? maxWidth;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth =
        maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);

    if (effectiveMaxWidth == null) {
      return child;
    }

    return center
        ? Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
              child: child,
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            child: child,
          );
  }
}
