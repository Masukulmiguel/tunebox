import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/song_list_tile.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../home/presentation/providers/songs_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../../models/song_model.dart';

class ArtistProfileScreen extends ConsumerStatefulWidget {
  final String artistId;

  const ArtistProfileScreen({super.key, required this.artistId});

  @override
  ConsumerState<ArtistProfileScreen> createState() =>
      _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends ConsumerState<ArtistProfileScreen> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(artistSongsProvider(widget.artistId));

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
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
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.purpleBlueGradient,
                          boxShadow:
                              AppShadows.colored(AppColors.primaryPurple),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.darkBackground,
                              width: 3,
                            ),
                          ),
                          child: const ClipOval(
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.textTertiary,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: const Text('Artista'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Nome do Artista',
                                  style: AppTypography.headlineMedium,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.primaryPurple,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '12.5K seguidores · 45 músicas',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _isFollowing = !_isFollowing);
                          },
                          icon: Icon(
                            _isFollowing
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _isFollowing ? 'A Seguir' : 'Seguir',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing
                                ? AppColors.darkSurfaceVariant
                                : AppColors.primaryPurple,
                            foregroundColor: _isFollowing
                                ? AppColors.textWhite
                                : AppColors.textWhite,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: _isFollowing
                                  ? const BorderSide(
                                      color: AppColors.darkBorder)
                                  : BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
          songsAsync.when(
            data: (songs) {
              if (songs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Nenhuma música publicada',
                      style: AppTypography.bodyMedium,
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
                      coverUrl: song.coverUrl,
                      trailing: song.formattedPlays,
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
            loading: () => SliverFillRemaining(
              child: ShimmerWidget.verticalList(count: 5),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
