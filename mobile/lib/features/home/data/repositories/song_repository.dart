import '../../../../models/song_model.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/supabase_file.dart';

class SongRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<SongModel>> getTrendingSongs({
    String region = 'angola',
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _supabase
        .from('songs')
        .select()
        .eq('is_approved', true)
        .order('plays_count', ascending: false)
        .range(offset, offset + limit - 1);

    return data.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<List<SongModel>> getNewReleases({int limit = 20, int offset = 0}) async {
    final data = await _supabase
        .from('songs')
        .select()
        .eq('is_approved', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return data.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<List<SongModel>> getMostPlayedSongs({int limit = 20, int offset = 0}) async {
    final data = await _supabase
        .from('songs')
        .select()
        .eq('is_approved', true)
        .order('plays_count', ascending: false)
        .range(offset, offset + limit - 1);

    return data.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<SongModel?> getSongById(String id) async {
    final data = await _supabase
        .from('songs')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return SongModel.fromJson(data);
  }

  Future<List<SongModel>> getSongsByArtist(String artistId, {int limit = 50}) async {
    final data = await _supabase
        .from('songs')
        .select()
        .eq('artist_id', artistId)
        .eq('is_approved', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return data.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<List<SongModel>> searchSongs(String query, {int limit = 20}) async {
    final data = await _supabase
        .from('songs')
        .select()
        .eq('is_approved', true)
        .or('title.ilike.%$query%,genre.ilike.%$query%')
        .order('plays_count', ascending: false)
        .limit(limit);

    return data.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<void> incrementPlayCount(String songId) async {
    await _supabase.rpc('increment_play_count', params: {'song_id': songId});
  }

  Future<void> likeSong(String songId) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    await _supabase.from('likes').insert({
      'user_id': userId,
      'song_id': songId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unlikeSong(String songId) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    await _supabase.from('likes').delete().match({
      'user_id': userId,
      'song_id': songId,
    });
  }

  Future<bool> isLiked(String songId) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return false;

    final data = await _supabase
        .from('likes')
        .select()
        .match({'user_id': userId, 'song_id': songId})
        .maybeSingle();

    return data != null;
  }

  Future<List<SongModel>> getLikedSongs({int limit = 50}) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return [];

    final data = await _supabase
        .from('likes')
        .select('songs(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return data
        .map((e) => SongModel.fromJson(e['songs']))
        .toList();
  }

  Future<void> incrementDownloadCount(String songId) async {
    await _supabase.rpc('increment_download_count', params: {'song_id': songId});
  }

  Future<String> uploadSong({
    required String title,
    required String artistId,
    required String audioPath,
    String? coverPath,
    String? albumId,
    String? genre,
    String? language,
    int? year,
    String? description,
    List<String>? tags,
    Duration? duration,
  }) async {
    final songId = DateTime.now().millisecondsSinceEpoch.toString();

    final audioFile = await SupabaseFile.fromPath(audioPath);
    final audioUrlPath = 'songs/$artistId/${songId}_audio.${audioFile.extension}';
    await _supabase.storage.from('songs').upload(audioUrlPath, audioFile.path);
    final audioUrl = _supabase.storage.from('songs').getPublicUrl(audioUrlPath);

    String? coverUrl;
    if (coverPath != null) {
      final coverFile = await SupabaseFile.fromPath(coverPath);
      final coverUrlPath = 'covers/$artistId/${songId}_cover.${coverFile.extension}';
      await _supabase.storage.from('covers').upload(coverUrlPath, coverFile.path);
      coverUrl = _supabase.storage.from('covers').getPublicUrl(coverUrlPath);
    }

    final now = DateTime.now().toIso8601String();
    await _supabase.from('songs').insert({
      'id': songId,
      'title': title,
      'artist_id': artistId,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
      'album_id': albumId,
      'genre': genre,
      'language': language,
      'year': year,
      'description': description,
      'tags': tags,
      'duration': duration?.inSeconds ?? 0,
      'is_approved': false,
      'created_at': now,
      'updated_at': now,
    });

    return songId;
  }

  Future<void> deleteSong(String songId) async {
    await _supabase.from('songs').delete().eq('id', songId);
  }
}
