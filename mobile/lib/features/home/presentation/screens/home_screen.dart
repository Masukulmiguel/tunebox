import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/animated_song_card.dart';
import '../../../../core/widgets/animated_song_list_tile.dart';
import '../../../../core/widgets/section_header.dart';
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
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/icons/icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    'TuneBox',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(
                    AppIcons.notification,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                _buildGreeting(),
                const SizedBox(height: AppSpacing.xxl),
                _buildQuickActions(),
                const SizedBox(height: AppSpacing.xxl),
                _buildTrendingSection(),
                const SizedBox(height: AppSpacing.xxl),
                _buildNewReleasesSection(),
                const SizedBox(height: AppSpacing.xxl),
                _buildTopArtistsSection(),
                const SizedBox(height: AppSpacing.miniPlayerHeight + 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Descobre música agora',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          _buildQuickActionCard(
            icon: Icons.trending_up_rounded,
            label: 'Tendências',
            color: AppColors.primaryPurple,
            onTap: () {},
          ),
          const SizedBox(width: AppSpacing.md),
          _buildQuickActionCard(
            icon: Icons.new_releases_rounded,
            label: 'Novidades',
            color: AppColors.primaryBlue,
            onTap: () {},
          ),
          const SizedBox(width: AppSpacing.md),
          _buildQuickActionCard(
            icon: Icons.shuffle_rounded,
            label: 'Mix',
            color: AppColors.accentPink,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    final charts = ref.watch(chartsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Em Alta', actionText: 'Ver tudo'),
        const SizedBox(height: AppSpacing.md),
        charts.when(
          data: (songs) => SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              itemCount: songs.length.clamp(0, 10),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: AnimatedSongCard(
                    index: index,
                    title: songs[index].title,
                    subtitle: songs[index].artistName,
                    coverUrl: songs[index].coverUrl,
                    onTap: () {
                      ref.read(currentSongProvider.notifier).state =
                          songs[index];
                      ref.read(playerQueueProvider.notifier).state = songs;
                      context.push('/player');
                    },
                  ),
                );
              },
            ),
          ),
          loading: () => ShimmerWidget.horizontalList(),
          error: (_, __) => const SizedBox(height: 200),
        ),
      ],
    );
  }

  Widget _buildNewReleasesSection() {
    final newReleases = ref.watch(newReleasesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Novos Lançamentos', actionText: 'Ver tudo'),
        const SizedBox(height: AppSpacing.md),
        newReleases.when(
          data: (songs) => Column(
            children: List.generate(
              songs.length.clamp(0, 5),
              (index) => AnimatedSongListTile(
                animIndex: index,
                title: songs[index].title,
                subtitle: songs[index].artistName,
                coverUrl: songs[index].coverUrl,
                trailing: songs[index].formattedDuration,
                onTap: () {
                  ref.read(currentSongProvider.notifier).state = songs[index];
                  ref.read(playerQueueProvider.notifier).state = songs;
                  context.push('/player');
                },
              ),
            ),
          ),
          loading: () => ShimmerWidget.verticalList(count: 5),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildTopArtistsSection() {
    final topArtists = ref.watch(topArtistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Artistas Populares', actionText: 'Ver tudo'),
        const SizedBox(height: AppSpacing.md),
        topArtists.when(
          data: (songs) => SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              itemCount: songs.length.clamp(0, 8),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _buildArtistAvatar(songs[index]),
                );
              },
            ),
          ),
          loading: () => const SizedBox(height: 120),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildArtistAvatar(SongModel song) {
    return GestureDetector(
      onTap: () {
        ref.read(currentSongProvider.notifier).state = song;
        context.push('/player');
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.3),
                  AppColors.primaryBlue.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: (song.coverUrl ?? '').isNotEmpty
                  ? Image.network(
                      song.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: AppColors.textSecondary,
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              song.artistName ?? 'Desconhecido',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
