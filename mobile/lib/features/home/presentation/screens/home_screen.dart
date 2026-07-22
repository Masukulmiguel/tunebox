import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/song_card.dart';
import '../../../../core/widgets/artist_card.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../providers/songs_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../../models/song_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.darkBackground,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/icon.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: AppColors.textWhite,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'TuneBox',
                  style: AppTypography.titleLarge,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  AppIcons.notification,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildBanner(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildTrendingSection(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildNewReleasesSection(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildTopArtistsSection(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildMostPlayedSection(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildGenresSection(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildForYouSection(),
                const SizedBox(height: AppSpacing.xxxxxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF1A0533)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NOVO',
                    style: AppTypography.labelSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Descubra a Música\nAngolana',
                  style: AppTypography.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Os melhores artistas nacionais',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    final trending = ref.watch(chartsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Top Charts',
          actionText: 'Ver tudo',
        ),
        const SizedBox(height: AppSpacing.sectionHeaderGap),
        trending.when(
          data: (songs) {
            if (songs.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Sem músicas disponíveis',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              );
            }
            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.lg,
                ),
                itemCount: songs.length.clamp(0, 10),
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  return SongCard(
                    title: songs[index].title,
                    subtitle: songs[index].artistName,
                    coverUrl: songs[index].coverUrl,
                    onTap: () {
                      ref.read(currentSongProvider.notifier).state =
                          songs[index];
                      ref.read(playerQueueProvider.notifier).state = songs;
                      context.push('/player');
                    },
                  );
                },
              ),
            );
          },
          loading: () => ShimmerWidget.horizontalList(),
          error: (_, __) => const SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildNewReleasesSection() {
    final newReleases = ref.watch(newReleasesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Novos Lançamentos',
          actionText: 'Ver tudo',
        ),
        const SizedBox(height: AppSpacing.sectionHeaderGap),
        newReleases.when(
          data: (songs) {
            if (songs.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Sem lançamentos recentes',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              );
            }
            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.lg,
                ),
                itemCount: songs.length.clamp(0, 10),
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  return SongCard(
                    title: songs[index].title,
                    subtitle: songs[index].artistName,
                    coverUrl: songs[index].coverUrl,
                    onTap: () {
                      ref.read(currentSongProvider.notifier).state =
                          songs[index];
                      context.push('/player');
                    },
                  );
                },
              ),
            );
          },
          loading: () => ShimmerWidget.horizontalList(),
          error: (_, __) => const SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildTopArtistsSection() {
    final topArtists = ref.watch(topArtistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Top Artistas',
          actionText: 'Ver todos',
        ),
        const SizedBox(height: AppSpacing.sectionHeaderGap),
        topArtists.when(
          data: (songs) {
            if (songs.isEmpty) return const SizedBox(height: 130);
            final seenArtists = <String>{};
            final uniqueArtistSongs = <SongModel>[];
            for (final song in songs) {
              if (song.artistName != null && !seenArtists.contains(song.artistName)) {
                seenArtists.add(song.artistName!);
                uniqueArtistSongs.add(song);
              }
            }
            return SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.lg,
                ),
                itemCount: uniqueArtistSongs.length.clamp(0, 10),
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.lg),
                itemBuilder: (context, index) {
                  final song = uniqueArtistSongs[index];
                  return ArtistCard(
                    name: song.artistName ?? '',
                    avatarUrl: song.coverUrl,
                    onTap: () {},
                  );
                },
              ),
            );
          },
          loading: () => ShimmerWidget.horizontalList(),
          error: (_, __) => const SizedBox(height: 130),
        ),
      ],
    );
  }

  Widget _buildMostPlayedSection() {
    final mostPlayed = ref.watch(chartsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Mais Tocadas',
          actionText: 'Ver todas',
        ),
        const SizedBox(height: AppSpacing.sectionHeaderGap),
        mostPlayed.when(
          data: (songs) {
            if (songs.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Sem dados disponíveis',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: songs.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final song = entry.value;
                  return _buildTrendingTile(index, song, songs);
                }).toList(),
              ),
            );
          },
          loading: () => ShimmerWidget.verticalList(count: 3),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildTrendingTile(int index, SongModel song, List<SongModel> allSongs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: () {
          ref.read(currentSongProvider.notifier).state = song;
          ref.read(playerQueueProvider.notifier).state = allSongs;
          context.push('/player');
        },
        child: Row(
          children: [
            Container(
              width: 24,
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: AppTypography.bodyMedium.copyWith(
                  color: index < 3
                      ? AppColors.primaryPurple
                      : AppColors.textTertiary,
                  fontWeight: index < 3 ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                song.coverUrl ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.darkSurfaceVariant,
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artistName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              song.formattedPlays,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenresSection() {
    final genres = [
      'Kizomba', 'Kuduro', 'Semba', 'Afrobeat',
      'R&B', 'Pop', 'Hip Hop', 'Gospel',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Géneros'),
        const SizedBox(height: AppSpacing.sectionHeaderGap),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            itemCount: genres.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: index == 0
                      ? AppColors.primaryGradient
                      : null,
                  color: index == 0 ? null : AppColors.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: index == 0
                        ? Colors.transparent
                        : AppColors.darkBorder,
                  ),
                ),
                child: Text(
                  genres[index],
                  style: AppTypography.labelMedium.copyWith(
                    color: index == 0
                        ? AppColors.textWhite
                        : AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForYouSection() {
    final charts = ref.watch(chartsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Feito para Si',
          actionText: 'Ver mais',
        ),
        const SizedBox(height: AppSpacing.sectionHeaderGap),
        charts.when(
          data: (songs) {
            if (songs.isEmpty) return const SizedBox();
            final shuffled = List<SongModel>.from(songs)..shuffle();
            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.lg,
                ),
                itemCount: shuffled.length.clamp(0, 6),
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  return SongCard(
                    title: shuffled[index].title,
                    subtitle: shuffled[index].artistName,
                    coverUrl: shuffled[index].coverUrl,
                    onTap: () {
                      ref.read(currentSongProvider.notifier).state =
                          shuffled[index];
                      ref.read(playerQueueProvider.notifier).state = songs;
                      context.push('/player');
                    },
                  );
                },
              ),
            );
          },
          loading: () => ShimmerWidget.horizontalList(),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }
}
