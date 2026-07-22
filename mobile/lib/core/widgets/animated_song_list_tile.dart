import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AnimatedSongListTile extends StatefulWidget {
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
  final int animIndex;

  const AnimatedSongListTile({
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
    this.animIndex = 0,
  });

  @override
  State<AnimatedSongListTile> createState() => _AnimatedSongListTileState();
}

class _AnimatedSongListTileState extends State<AnimatedSongListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.animIndex * 60).clamp(0, 300)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 3,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: _isPressed
                  ? AppColors.primaryPurple.withValues(alpha: 0.1)
                  : widget.isPlaying
                      ? AppColors.primaryPurple.withValues(alpha: 0.08)
                      : Colors.transparent,
              borderRadius: AppRadius.radiusMD,
              border: widget.isPlaying
                  ? Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (widget.showIndex && widget.index != null) ...[
                  SizedBox(
                    width: 28,
                    child: Center(
                      child: widget.isPlaying
                          ? _buildEqualizerIcon()
                          : Text(
                              '${widget.index! + 1}',
                              style: TextStyle(
                                color: AppColors.textTertiary.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: AppSpacing.md),
                ],
                if (widget.coverUrl != null)
                  ClipRRect(
                    borderRadius: AppRadius.radiusXS,
                    child: Image.network(
                      widget.coverUrl!,
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
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.isPlaying
                              ? AppColors.primaryPurple
                              : AppColors.textPrimary,
                          fontWeight:
                              widget.isPlaying ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14.5,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.trailing!,
                    style: TextStyle(
                      color: AppColors.textTertiary.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (widget.onMoreTap != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: widget.onMoreTap,
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textTertiary.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEqualizerIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 3,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          height: [12, 16, 10][i].toDouble(),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      width: AppSpacing.albumCoverSmall,
      height: AppSpacing.albumCoverSmall,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkSurfaceVariant, AppColors.darkElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.radiusXS,
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: AppColors.primaryPurple.withValues(alpha: 0.4),
        size: 20,
      ),
    );
  }
}
