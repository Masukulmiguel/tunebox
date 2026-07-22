import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ArtistCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? subtitle;
  final VoidCallback? onTap;

  const ArtistCard({
    super.key,
    required this.name,
    this.avatarUrl,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.purpleBlueGradient,
                boxShadow: AppShadows.colored(AppColors.primaryPurple),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.darkBackground,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: avatarUrl != null
                      ? Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                        )
                      : _buildAvatarPlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
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
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.darkSurfaceVariant,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}
