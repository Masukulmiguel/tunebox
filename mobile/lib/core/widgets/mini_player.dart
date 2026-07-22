import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class MiniPlayer extends StatelessWidget {
  final String title;
  final String? artist;
  final String? coverUrl;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final double? progress;

  const MiniPlayer({
    super.key,
    required this.title,
    this.artist,
    this.coverUrl,
    this.isPlaying = false,
    this.onTap,
    this.onPlayPause,
    this.onNext,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.miniPlayerHeight,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkSurfaceVariant,
              AppColors.darkElevated,
            ],
          ),
          borderRadius: AppRadius.radiusMD,
          boxShadow: AppShadows.medium,
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.radiusXS,
                      child: coverUrl != null
                          ? Image.network(
                              coverUrl!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildCoverPlaceholder(),
                            )
                          : _buildCoverPlaceholder(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (artist != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              artist!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onPlayPause,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.textWhite,
                          size: 24,
                        ),
                      ),
                    ),
                    if (onNext != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: onNext,
                        child: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textWhite,
                          size: 28,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (progress != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.md),
                ),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor: AppColors.darkBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryPurple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: AppRadius.radiusXS,
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: AppColors.textTertiary,
        size: 20,
      ),
    );
  }
}
