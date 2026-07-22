import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class SongCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final VoidCallback? onTap;
  final bool isCompact;

  const SongCard({
    super.key,
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isCompact ? 120.0 : 160.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: AppRadius.cardRadius,
                boxShadow: AppShadows.medium,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.cardRadius,
                child: coverUrl != null
                    ? Image.network(
                        coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: AppRadius.cardRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.textTertiary,
          size: 36,
        ),
      ),
    );
  }
}
