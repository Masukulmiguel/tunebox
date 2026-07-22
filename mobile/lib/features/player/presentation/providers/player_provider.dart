import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/audio_player_service.dart';
import '../../../../models/song_model.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService.instance;
});

final currentSongProvider = StateProvider<SongModel?>((ref) {
  return null;
});

final isPlayingProvider = StateProvider<bool>((ref) => false);

final playerQueueProvider = StateProvider<List<SongModel>>((ref) => []);

final shuffleProvider = StateProvider<bool>((ref) => false);

final repeatProvider = StateProvider<RepeatMode>((ref) => RepeatMode.off);

enum RepeatMode { off, all, one }

final positionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerServiceProvider).positionStream;
});

final durationProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerServiceProvider).durationStream.where((d) => d != null).cast<Duration>();
});
