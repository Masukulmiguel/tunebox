import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/song_model.dart';

class DownloadService {
  static DownloadService? _instance;

  DownloadService._();

  static DownloadService get instance {
    _instance ??= DownloadService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (kIsWeb) return;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    return true;
  }

  Future<String?> downloadSong(SongModel song) async {
    if (kIsWeb) return null;
    return null;
  }

  Future<void> cancelDownload(String taskId) async {}
  Future<void> pauseDownload(String taskId) async {}
  Future<String?> resumeDownload(String taskId) async => null;
  Future<String?> retryDownload(String taskId) async => null;

  Future<bool> deleteDownload(String filePath) async {
    if (kIsWeb) return false;
    return false;
  }

  Future<List<String>> getDownloadedFiles() async {
    if (kIsWeb) return [];
    return [];
  }

  Future<bool> isSongDownloaded(String songId) async {
    if (kIsWeb) return false;
    return false;
  }

  Stream<dynamic> get onDownloadUpdate => const Stream.empty();

  Future<void> openFile(String filePath) async {}
}
