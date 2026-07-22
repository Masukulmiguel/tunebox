import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static CacheService? _instance;
  late Box _cacheBox;
  late Box _favoritesBox;
  late Box _historyBox;
  late Box _playlistsBox;
  late Box _settingsBox;

  CacheService._();

  static CacheService get instance {
    _instance ??= CacheService._();
    return _instance!;
  }

  Future<void> initialize() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('cache');
    _favoritesBox = await Hive.openBox('favorites');
    _historyBox = await Hive.openBox('history');
    _playlistsBox = await Hive.openBox('playlists');
    _settingsBox = await Hive.openBox('settings');
  }

  // ── Generic Cache ──
  Future<void> set(String key, dynamic value) async {
    await _cacheBox.put(key, value);
  }

  T? get<T>(String key) {
    return _cacheBox.get(key) as T?;
  }

  Future<void> remove(String key) async {
    await _cacheBox.delete(key);
  }

  Future<void> clear() async {
    await _cacheBox.clear();
  }

  // ── Favorites ──
  Future<void> addFavorite(String songId) async {
    final favorites = getFavorites();
    if (!favorites.contains(songId)) {
      favorites.add(songId);
      await _favoritesBox.put('songs', favorites);
    }
  }

  Future<void> removeFavorite(String songId) async {
    final favorites = getFavorites();
    favorites.remove(songId);
    await _favoritesBox.put('songs', favorites);
  }

  List<String> getFavorites() {
    final data = _favoritesBox.get('songs');
    if (data == null) return [];
    return List<String>.from(data);
  }

  bool isFavorite(String songId) {
    return getFavorites().contains(songId);
  }

  // ── History ──
  Future<void> addToHistory(String songId) async {
    final history = getHistory();
    history.remove(songId);
    history.insert(0, songId);
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    await _historyBox.put('songs', history);
  }

  Future<void> clearHistory() async {
    await _historyBox.put('songs', <String>[]);
  }

  List<String> getHistory() {
    final data = _historyBox.get('songs');
    if (data == null) return [];
    return List<String>.from(data);
  }

  // ── Playlists Cache ──
  Future<void> cachePlaylist(String playlistId, Map<String, dynamic> data) async {
    await _playlistsBox.put(playlistId, data);
  }

  Map<String, dynamic>? getCachedPlaylist(String playlistId) {
    final data = _playlistsBox.get(playlistId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // ── Settings ──
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  bool get isDarkMode => getSetting('dark_mode') ?? true;
  String get language => getSetting('language') ?? 'pt';
  bool get highQuality => getSetting('high_quality') ?? false;

  Future<void> dispose() async {
    await Hive.close();
  }
}
