import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../../../models/playlist_model.dart';
import '../../../../models/song_model.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return null;
});

final userPlaylistsProvider = FutureProvider<List<PlaylistModel>>((ref) async {
  final repo = ref.watch(playlistRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return repo.getUserPlaylists(userId);
});

final publicPlaylistsProvider = FutureProvider<List<PlaylistModel>>((ref) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getPublicPlaylists();
});

final playlistDetailProvider =
    FutureProvider.family<PlaylistModel?, String>((ref, playlistId) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getPlaylistById(playlistId);
});

final playlistSongsProvider =
    FutureProvider.family<List<SongModel>, String>((ref, playlistId) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getPlaylistSongs(playlistId);
});
