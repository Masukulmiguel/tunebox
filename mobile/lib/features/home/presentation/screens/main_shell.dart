import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mini_player.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../home/presentation/providers/app_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final _navItems = const [
    {'label': 'Home', 'icon': AppIcons.home, 'path': '/'},
    {'label': 'Pesquisar', 'icon': AppIcons.search, 'path': '/search'},
    {'label': '', 'icon': AppIcons.add, 'path': '/upload'},
    {'label': 'Biblioteca', 'icon': AppIcons.library, 'path': '/library'},
    {'label': 'Perfil', 'icon': AppIcons.profile, 'path': '/profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final currentSong = ref.watch(currentSongProvider);
    final audioService = ref.watch(audioPlayerServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            bottom: currentSong != null ? AppSpacing.miniPlayerHeight + 16 : 0,
            child: widget.child,
          ),
          if (currentSong != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.bottomNavHeight,
              child: StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = audioService.duration;
                  final progress = total.inMilliseconds > 0
                      ? (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
                      : 0.0;
                  return MiniPlayer(
                    title: currentSong.title,
                    artist: currentSong.artistName,
                    coverUrl: currentSong.coverUrl,
                    isPlaying: audioService.isPlaying,
                    progress: progress,
                    onTap: () => context.push('/player'),
                    onPlayPause: () async {
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
                    onNext: () => audioService.skipToNext(),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          border: Border(
            top: BorderSide(
              color: AppColors.darkBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = currentIndex == index;
                final isUpload = index == 2;

                if (isUpload) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => context.push(item['path'] as String),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            AppIcons.add,
                            color: AppColors.textWhite,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).state = index;
                      context.go(item['path'] as String);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isActive
                              ? AppColors.primaryPurple
                              : AppColors.textTertiary,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppColors.primaryPurple
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
