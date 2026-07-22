import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_icons.dart';
import '../providers/player_provider.dart';
import '../../data/services/audio_player_service.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongProvider);
    final audioService = ref.watch(audioPlayerServiceProvider);
    final shuffleEnabled = ref.watch(shuffleProvider);
    final repeatMode = ref.watch(repeatProvider);

    if (currentSong == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Nenhuma música selecionada',
            style: AppTypography.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0533), AppColors.darkBackground],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              const Spacer(flex: 2),
              _buildAlbumArt(currentSong.coverUrl),
              const Spacer(flex: 2),
              _buildSongInfo(currentSong),
              const SizedBox(height: AppSpacing.xl),
              _buildProgressIndicator(audioService),
              const SizedBox(height: AppSpacing.xl),
              _buildControls(ref, audioService, shuffleEnabled, repeatMode),
              const SizedBox(height: AppSpacing.xxl),
              _buildBottomActions(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 32,
            ),
            onPressed: () => context.pop(),
          ),
          Column(
            children: [
              Text(
                'A reproduzir da',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Text(
                'Biblioteca',
                style: AppTypography.labelLarge,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              AppIcons.moreVertical,
              color: AppColors.textSecondary,
            ),
            onPressed: () => _showPlayerOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(String? coverUrl) {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateController.value * 2 * pi * 0.1,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkSurfaceVariant,
                        AppColors.darkElevated,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkBackground,
                    border: Border.all(
                      color: AppColors.darkBorder,
                      width: 2,
                    ),
                  ),
                ),
                if (coverUrl != null)
                  ClipOval(
                    child: Image.network(
                      coverUrl,
                      width: 260,
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.music_note_rounded,
                        color: AppColors.textTertiary,
                        size: 64,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.music_note_rounded,
                    color: AppColors.textTertiary,
                    size: 64,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongInfo(dynamic song) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  song.artistName ?? 'Desconhecido',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FULL SONG',
                    style: AppTypography.labelSmall,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              AppIcons.like,
              color: AppColors.textSecondary,
              size: 26,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AudioPlayerService audioService) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          StreamBuilder<Duration>(
            stream: audioService.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = audioService.duration;
              final totalMs = total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0;
              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: AppColors.textWhite,
                  inactiveTrackColor: AppColors.darkBorder,
                  thumbColor: AppColors.textWhite,
                  overlayColor: AppColors.textWhite.withValues(alpha: 0.1),
                ),
                child: Slider(
                  value: (position.inMilliseconds.toDouble()).clamp(0.0, totalMs) as double,
                  max: totalMs,
                  onChanged: (value) {
                    audioService.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<Duration>(
                  stream: audioService.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Text(
                      _formatDuration(position),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                ),
                Text(
                  '-${_formatDuration(audioService.duration)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildControls(
    WidgetRef ref,
    AudioPlayerService audioService,
    bool shuffleEnabled,
    RepeatMode repeatMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(shuffleProvider.notifier).state = !shuffleEnabled;
              audioService.toggleShuffle();
            },
            child: Icon(
              AppIcons.shuffle,
              color: shuffleEnabled
                  ? AppColors.primaryPurple
                  : AppColors.textTertiary,
              size: 24,
            ),
          ),
          GestureDetector(
            onTap: () => audioService.skipToPrevious(),
            child: const Icon(
              AppIcons.skipPrevious,
              color: AppColors.textWhite,
              size: 36,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final currentSong = ref.read(currentSongProvider);
              if (currentSong == null) return;

              if (audioService.isPlaying) {
                await audioService.pause();
                ref.read(isPlayingProvider.notifier).state = false;
              } else {
                final queue = ref.read(playerQueueProvider);
                if (audioService.currentSong == null) {
                  await audioService.play(currentSong, queue: queue.isNotEmpty ? queue : null);
                } else {
                  await audioService.resume();
                }
                ref.read(isPlayingProvider.notifier).state = true;
              }
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: audioService.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        color: AppColors.textWhite,
                        strokeWidth: 3,
                      ),
                    )
                  : Icon(
                      audioService.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.textWhite,
                      size: 40,
                    ),
            ),
          ),
          GestureDetector(
            onTap: () => audioService.skipToNext(),
            child: const Icon(
              AppIcons.skipNext,
              color: AppColors.textWhite,
              size: 36,
            ),
          ),
          GestureDetector(
            onTap: () {
              final modes = RepeatMode.values;
              final nextIndex = (repeatMode.index + 1) % modes.length;
              ref.read(repeatProvider.notifier).state = modes[nextIndex];
              audioService.toggleLoop();
            },
            child: Icon(
              repeatMode == RepeatMode.one
                  ? AppIcons.repeatOne
                  : AppIcons.repeat,
              color: repeatMode != RepeatMode.off
                  ? AppColors.primaryPurple
                  : AppColors.textTertiary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              AppIcons.cast,
              color: AppColors.textTertiary,
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              AppIcons.download,
              color: AppColors.textTertiary,
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              AppIcons.share,
              color: AppColors.textTertiary,
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              AppIcons.queue,
              color: AppColors.textTertiary,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showPlayerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildOptionTile(
                Icons.playlist_add_rounded,
                'Adicionar a playlist',
              ),
              _buildOptionTile(
                Icons.timer_outlined,
                'Adicionar ao timer',
              ),
              _buildOptionTile(
                Icons.info_outline_rounded,
                'Ver informações',
              ),
              _buildOptionTile(
                AppIcons.report,
                'Reportar problema',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}
