import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/song_repository.dart';
import '../../../../models/song_model.dart';
import '../../../../services/music_service.dart';

final musicServiceProvider = Provider<MusicService>((ref) {
  return MusicService.instance;
});

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository();
});

final trendingSongsProvider = FutureProvider<List<SongModel>>((ref) async {
  final musicService = ref.watch(musicServiceProvider);
  return musicService.getCharts(limit: 20);
});

final chartsProvider = FutureProvider<List<SongModel>>((ref) async {
  final musicService = ref.watch(musicServiceProvider);
  return musicService.getCharts(limit: 25);
});

final newReleasesProvider = FutureProvider<List<SongModel>>((ref) async {
  final musicService = ref.watch(musicServiceProvider);
  return musicService.getNewReleases(limit: 20);
});

final mostPlayedProvider = FutureProvider<List<SongModel>>((ref) async {
  final musicService = ref.watch(musicServiceProvider);
  return musicService.getCharts(limit: 15);
});

final topArtistsProvider = FutureProvider<List<SongModel>>((ref) async {
  final musicService = ref.watch(musicServiceProvider);
  return musicService.getTopArtists(limit: 20);
});

final songSearchProvider =
    StateNotifierProvider<SongSearchNotifier, AsyncValue<List<SongModel>>>((ref) {
  return SongSearchNotifier(ref);
});

class SongSearchNotifier extends StateNotifier<AsyncValue<List<SongModel>>> {
  final Ref _ref;

  SongSearchNotifier(this._ref) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final musicService = _ref.read(musicServiceProvider);
      final results = await musicService.search(query, limit: 25);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

final artistSongsProvider =
    FutureProvider.family<List<SongModel>, String>((ref, artistId) async {
  final musicService = ref.watch(musicServiceProvider);
  return musicService.getArtistTopTracks(artistId, limit: 20);
});

final genreTracksProvider =
    FutureProvider.family<List<SongModel>, String>((ref, genreId) async {
  final musicService = ref.watch(musicServiceProvider);
  return musicService.search(genreId, limit: 20);
});

final likedSongsProvider = FutureProvider<List<SongModel>>((ref) async {
  try {
    final repo = ref.watch(songRepositoryProvider);
    return repo.getLikedSongs();
  } catch (_) {
    return [];
  }
});
