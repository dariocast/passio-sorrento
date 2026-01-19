/// Live badge widget with pulsing animation.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated "LIVE" badge that pulses to indicate active status.
class LiveBadge extends StatefulWidget {
  const LiveBadge({
    super.key,
    this.label = 'LIVE',
    this.size = LiveBadgeSize.medium,
    this.animate = true,
  });

  /// The label to display. Defaults to "LIVE".
  final String label;

  /// Size of the badge.
  final LiveBadgeSize size;

  /// Whether to animate the badge.
  final bool animate;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiveBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.size._config;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: config.horizontalPadding,
              vertical: config.verticalPadding,
            ),
            decoration: BoxDecoration(
              color: AppColors.live,
              borderRadius: BorderRadius.circular(config.borderRadius),
              boxShadow: widget.animate
                  ? [
                      BoxShadow(
                        color: AppColors.live.withAlpha(
                          (_glowAnimation.value * 255).toInt(),
                        ),
                        blurRadius: config.glowRadius,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (config.showDot) ...[
                  Container(
                    width: config.dotSize,
                    height: config.dotSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: config.dotSpacing),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: AppColors.onLive,
                    fontWeight: FontWeight.w700,
                    fontSize: config.fontSize,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Size variants for LiveBadge.
enum LiveBadgeSize {
  small(_SmallBadgeConfig()),
  medium(_MediumBadgeConfig()),
  large(_LargeBadgeConfig());

  const LiveBadgeSize(this._config);
  final _BadgeConfig _config;
}

abstract class _BadgeConfig {
  double get fontSize;
  double get horizontalPadding;
  double get verticalPadding;
  double get borderRadius;
  double get glowRadius;
  bool get showDot;
  double get dotSize;
  double get dotSpacing;
}

class _SmallBadgeConfig implements _BadgeConfig {
  const _SmallBadgeConfig();

  @override
  double get fontSize => 9;
  @override
  double get horizontalPadding => 6;
  @override
  double get verticalPadding => 2;
  @override
  double get borderRadius => 4;
  @override
  double get glowRadius => 4;
  @override
  bool get showDot => false;
  @override
  double get dotSize => 0;
  @override
  double get dotSpacing => 0;
}

class _MediumBadgeConfig implements _BadgeConfig {
  const _MediumBadgeConfig();

  @override
  double get fontSize => 11;
  @override
  double get horizontalPadding => 8;
  @override
  double get verticalPadding => 4;
  @override
  double get borderRadius => 6;
  @override
  double get glowRadius => 6;
  @override
  bool get showDot => true;
  @override
  double get dotSize => 6;
  @override
  double get dotSpacing => 4;
}

class _LargeBadgeConfig implements _BadgeConfig {
  const _LargeBadgeConfig();

  @override
  double get fontSize => 14;
  @override
  double get horizontalPadding => 12;
  @override
  double get verticalPadding => 6;
  @override
  double get borderRadius => 8;
  @override
  double get glowRadius => 8;
  @override
  bool get showDot => true;
  @override
  double get dotSize => 8;
  @override
  double get dotSpacing => 6;
}

/// A simpler live indicator dot without text.
class LiveDot extends StatefulWidget {
  const LiveDot({
    super.key,
    this.size = 8,
    this.color = AppColors.live,
    this.animate = true,
  });

  final double size;
  final Color color;
  final bool animate;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
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
        return Container(
          width: widget.size * (widget.animate ? _scaleAnimation.value : 1.0),
          height: widget.size * (widget.animate ? _scaleAnimation.value : 1.0),
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: widget.animate
                ? [
                    BoxShadow(
                      color: widget.color.withAlpha(100),
                      blurRadius: widget.size,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
