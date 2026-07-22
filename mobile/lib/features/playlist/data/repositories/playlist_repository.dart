import '../../../../models/playlist_model.dart';
import '../../../../models/song_model.dart';
import '../../../../services/supabase_service.dart';

class PlaylistRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<PlaylistModel> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    bool isPublic = true,
  }) async {
    final userId = _supabase.currentUserId;
    if (userId == null) throw Exception('Não autenticado');

    final now = DateTime.now();
    final data = {
      'name': name,
      'user_id': userId,
      'description': description,
      'cover_url': coverUrl,
      'is_public': isPublic,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _supabase
        .from('playlists')
        .insert(data)
        .select()
        .single();

    return PlaylistModel.fromJson(response);
  }

  Future<void> updatePlaylist(String playlistId, {
    String? name,
    String? description,
    String? coverUrl,
    bool? isPublic,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (coverUrl != null) updates['cover_url'] = coverUrl;
    if (isPublic != null) updates['is_public'] = isPublic;

    await _supabase.from('playlists').update(updates).eq('id', playlistId);
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _supabase.from('playlists').delete().eq('id', playlistId);
  }

  Future<PlaylistModel?> getPlaylistById(String id) async {
    final data = await _supabase
        .from('playlists')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return PlaylistModel.fromJson(data);
  }

  Future<List<PlaylistModel>> getUserPlaylists(String userId) async {
    final data = await _supabase
        .from('playlists')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return data.map((e) => PlaylistModel.fromJson(e)).toList();
  }

  Future<List<PlaylistModel>> getPublicPlaylists({int limit = 20}) async {
    final data = await _supabase
        .from('playlists')
        .select()
        .eq('is_public', true)
        .order('likes_count', ascending: false)
        .limit(limit);

    return data.map((e) => PlaylistModel.fromJson(e)).toList();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _supabase.from('playlist_songs').insert({
      'playlist_id': playlistId,
      'song_id': songId,
      'added_at': DateTime.now().toIso8601String(),
    });

    await _supabase.rpc('increment_playlist_songs_count', params: {
      'playlist_id': playlistId,
    });
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _supabase.from('playlist_songs').delete().match({
      'playlist_id': playlistId,
      'song_id': songId,
    });

    await _supabase.rpc('decrement_playlist_songs_count', params: {
      'playlist_id': playlistId,
    });
  }

  Future<List<SongModel>> getPlaylistSongs(String playlistId) async {
    final data = await _supabase
        .from('playlist_songs')
        .select('songs(*)')
        .eq('playlist_id', playlistId)
        .order('added_at', ascending: true);

    return data
        .map((e) => SongModel.fromJson(e['songs']))
        .toList();
  }

  Future<void> likePlaylist(String playlistId) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    await _supabase.from('playlist_likes').insert({
      'user_id': userId,
      'playlist_id': playlistId,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _supabase.rpc('increment_playlist_likes_count', params: {
      'playlist_id': playlistId,
    });
  }

  Future<void> unlikePlaylist(String playlistId) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    await _supabase.from('playlist_likes').delete().match({
      'user_id': userId,
      'playlist_id': playlistId,
    });

    await _supabase.rpc('decrement_playlist_likes_count', params: {
      'playlist_id': playlistId,
    });
  }
}
