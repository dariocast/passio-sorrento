/// Skeleton loader widget for loading states.
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer loading skeleton effect.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  /// Width of the skeleton. If null, expands to fill available space.
  final double? width;

  /// Height of the skeleton.
  final double? height;

  /// Border radius of the skeleton.
  final BorderRadius? borderRadius;

  /// Optional child to show instead of a simple rectangle.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child:
          child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          ),
    );
  }
}

/// A skeleton that mimics a list tile.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.titleWidth = 0.6,
    this.subtitleWidth = 0.4,
  });

  final bool hasLeading;
  final bool hasTrailing;
  final double titleWidth;
  final double subtitleWidth;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (hasLeading)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            if (hasLeading) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: titleWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: subtitleWidth,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: 16),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A skeleton that mimics a card.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.height = 120,
    this.hasImage = false,
    this.imageHeight = 80,
  });

  final double height;
  final bool hasImage;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: hasImage
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: imageHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 14,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 10,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

/// A skeleton that mimics a weather card.
class SkeletonWeatherCard extends StatelessWidget {
  const SkeletonWeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A loading list that shows multiple skeleton items.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 5, this.itemBuilder});

  final int itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder:
          itemBuilder ??
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SkeletonCard(height: 80),
          ),
    );
  }
}
