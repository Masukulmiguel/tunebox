import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/song_list_tile.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../playlist/presentation/providers/playlist_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistDetailProvider(playlistId));
    final songsAsync = ref.watch(playlistSongsProvider(playlistId));

    return Scaffold(
      body: playlistAsync.when(
        data: (playlist) {
          if (playlist == null) {
            return const Center(
              child: Text('Playlist não encontrada'),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2D1B69), AppColors.darkBackground],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppShadows.large,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: playlist.coverUrl != null
                                  ? Image.network(
                                      playlist.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildCoverPlaceholder(),
                                    )
                                  : _buildCoverPlaceholder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text(
                    playlist.name,
                    style: AppTypography.titleLarge,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (playlist.description != null) ...[
                        Text(
                          playlist.description!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.music_note_rounded,
                            '${playlist.songsCount} músicas',
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildInfoChip(
                            Icons.favorite_border_rounded,
                            '${playlist.likesCount} curtidas',
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildInfoChip(
                            playlist.isPublic
                                ? Icons.public_rounded
                                : Icons.lock_rounded,
                            playlist.isPublic ? 'Pública' : 'Privada',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.play_arrow_rounded, size: 24),
                              label: const Text('Reproduzir'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                foregroundColor: AppColors.textWhite,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: AppColors.darkSurfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: const Icon(
                              Icons.shuffle_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              songsAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.queue_music_rounded,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Playlist vazia',
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
                        return SongListTile(
                          title: song.title,
                          subtitle: song.artistName,
                          coverUrl: song.coverUrl,
                          trailing: song.formattedDuration,
                          showIndex: true,
                          index: index,
                          onTap: () {
                            ref.read(currentSongProvider.notifier).state = song;
                            context.push('/player');
                          },
                        );
                      },
                      childCount: songs.length,
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Erro: $e')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: AppColors.darkSurfaceVariant,
      child: const Center(
        child: Icon(
          Icons.playlist_play_rounded,
          color: AppColors.textTertiary,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
