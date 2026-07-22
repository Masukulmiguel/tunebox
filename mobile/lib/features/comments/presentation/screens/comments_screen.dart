import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../comments/presentation/providers/comment_provider.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String songId;

  const CommentsScreen({super.key, required this.songId});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(songCommentsProvider(widget.songId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.primaryPurple,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Sem comentários',
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Seja o primeiro a comentar',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _buildCommentTile(comment);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Erro: $e'),
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildCommentTile(dynamic comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkSurfaceVariant,
            ),
            child: comment.userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      comment.userAvatar!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName ?? 'Utilizador',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_border_rounded,
                            color: AppColors.textTertiary,
                            size: 14,
                          ),
                          if (comment.likesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likesCount}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Responder',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryPurple,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.flag_outlined,
                        color: AppColors.textTertiary,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                ),
                decoration: const InputDecoration(
                  hintText: 'Escrever um comentário...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: AppColors.textWhite,
                size: 18,
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _controller.clear();
                  _focusNode.unfocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}sem';
  }
}
