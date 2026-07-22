import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class SongListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final String? trailing;
  final bool isPlaying;
  final bool showIndex;
  final int? index;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final Widget? leading;

  const SongListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.trailing,
    this.isPlaying = false,
    this.showIndex = false,
    this.index,
    this.onTap,
    this.onMoreTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusSM,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (showIndex && index != null) ...[
              SizedBox(
                width: 28,
                child: Center(
                  child: isPlaying
                      ? const Icon(
                          Icons.equalizer_rounded,
                          color: AppColors.primaryPurple,
                          size: 18,
                        )
                      : Text(
                          '${index! + 1}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.md),
            ],
            if (coverUrl != null)
              ClipRRect(
                borderRadius: AppRadius.radiusXS,
                child: Image.network(
                  coverUrl!,
                  width: AppSpacing.albumCoverSmall,
                  height: AppSpacing.albumCoverSmall,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
                ),
              )
            else
              _buildCoverPlaceholder(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isPlaying
                          ? AppColors.primaryPurple
                          : AppColors.textPrimary,
                      fontWeight:
                          isPlaying ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
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
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                trailing!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
            if (onMoreTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onMoreTap,
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      width: AppSpacing.albumCoverSmall,
      height: AppSpacing.albumCoverSmall,
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
