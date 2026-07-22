import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class ShimmerWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: borderRadius ?? AppRadius.radiusSM,
        ),
      ),
    );
  }

  static Widget songTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const ShimmerWidget(
            width: AppSpacing.albumCoverSmall,
            height: AppSpacing.albumCoverSmall,
            borderRadius: AppRadius.radiusXS,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerWidget(
                  width: double.infinity,
                  height: 14,
                ),
                const SizedBox(height: 6),
                const ShimmerWidget(
                  width: 100,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget horizontalCard() {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerWidget(
            width: 160,
            height: 160,
            borderRadius: AppRadius.radiusMD,
          ),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerWidget(width: 120, height: 14),
          const SizedBox(height: 4),
          const ShimmerWidget(width: 80, height: 12),
        ],
      ),
    );
  }

  static Widget horizontalList() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: AppSpacing.screenPadding),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) => horizontalCard(),
      ),
    );
  }

  static Widget verticalList({int count = 5}) {
    return Column(
      children: List.generate(count, (_) => songTile()),
    );
  }
}
