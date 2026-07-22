import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/song_model.dart';

class MusicService {
  static MusicService? _instance;
  MusicService._();
  static MusicService get instance => _instance ??= MusicService._();

  static const _baseUrl = 'http://127.0.0.1:9090';
  final Map<String, String> _streamCache = {};

  Future<List<SongModel>> search(String query, {int limit = 25}) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = '$_baseUrl/search?q=${Uri.encodeComponent(query)}&limit=$limit';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        debugPrint('Search failed: ${response.statusCode}');
        return [];
      }
      final data = json.decode(response.body);
      final songs = data['songs'] as List? ?? [];
      return songs.map((s) => _songFromResult(s)).toList();
    } catch (e) {
      debugPrint('Search error: $e');
      return [];
    }
  }

  Future<List<SongModel>> getCharts({int limit = 25}) async {
    return search('top hits 2025', limit: limit);
  }

  Future<List<SongModel>> getNewReleases({int limit = 25}) async {
    return search('new music releases 2025', limit: limit);
  }

  Future<List<SongModel>> getTopArtists({int limit = 20}) async {
    final results = await search('popular artists hits', limit: limit);
    return results.take(limit).toList();
  }

  Future<List<SongModel>> getArtistTopTracks(String artistId, {int limit = 10}) async {
    return search('$artistId hits', limit: limit);
  }

  Future<String?> getStreamUrl(String videoId) async {
    if (_streamCache.containsKey(videoId)) {
      return _streamCache[videoId];
    }
    try {
      final url = '$_baseUrl/stream?id=${Uri.encodeComponent(videoId)}';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body);
      final streamUrl = data['stream_url'] as String?;
      if (streamUrl != null) {
        _streamCache[videoId] = streamUrl;
      }
      return streamUrl;
    } catch (e) {
      debugPrint('Stream URL error: $e');
      return null;
    }
  }

  SongModel _songFromResult(Map<String, dynamic> song) {
    return SongModel(
      id: song['id'] ?? '',
      title: song['title'] ?? 'Sem título',
      artistId: '',
      artistName: song['artist'] ?? 'Desconhecido',
      albumId: null,
      albumName: song['album'],
      audioUrl: '',
      coverUrl: song['cover_url'] ?? '',
      genre: null,
      duration: Duration(seconds: song['duration'] ?? 0),
      playsCount: 0,
      isExplicit: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
