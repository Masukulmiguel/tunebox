import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/song_list_tile.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../home/presentation/providers/songs_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  const Text(
                    'Biblioteca',
                    style: AppTypography.headlineLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      AppIcons.add,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => context.push('/create-playlist'),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Favoritos'),
                Tab(text: 'Downloads'),
                Tab(text: 'Histórico'),
                Tab(text: 'Playlists'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFavoritesTab(),
                  _buildDownloadsTab(),
                  _buildHistoryTab(),
                  _buildPlaylistsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final likedSongs = ref.watch(likedSongsProvider);

    return likedSongs.when(
      data: (songs) {
        if (songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.likeFilled,
                    color: AppColors.primaryPurple,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Sem favoritos ainda',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Adicione músicas aos favoritos\npara as encontrar aqui',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongListTile(
              title: song.title,
              subtitle: song.artistName,
              coverUrl: song.coverUrl,
              trailing: song.formattedDuration,
              onTap: () {
                ref.read(currentSongProvider.notifier).state = song;
                context.push('/player');
              },
            );
          },
        );
      },
      loading: () => ShimmerWidget.verticalList(count: 5),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  Widget _buildDownloadsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.download,
              color: AppColors.primaryBlue,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Sem downloads',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Descarregue músicas para\nouvir offline',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.accentCyan,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Sem histórico',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'As músicas que ouvir\naparecerão aqui',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentPink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.playlist,
              color: AppColors.accentPink,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Sem playlists',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Crie playlists para organizar\nas suas músicas',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton.icon(
            onPressed: () => context.push('/create-playlist'),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Criar Playlist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: AppColors.textWhite,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
