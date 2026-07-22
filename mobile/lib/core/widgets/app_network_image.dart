import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildPlaceholder(context);
    }

    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.imageRadius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: AppColors.darkSurfaceVariant,
              child: const Center(
                child: Icon(
                  Icons.music_note_rounded,
                  color: AppColors.textTertiary,
                  size: 32,
                ),
              ),
            ),
        errorWidget: (context, url, error) => errorWidget ?? _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: borderRadius ?? AppRadius.imageRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}
