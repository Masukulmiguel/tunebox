import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../models/song_model.dart';
import '../../../../services/music_service.dart';

class AudioPlayerService {
  static AudioPlayerService? _instance;
  late final AudioPlayer _player;
  AudioHandler? _audioHandler;
  List<SongModel> _queue = [];
  int _currentIndex = -1;
  bool _shuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  bool _isLoading = false;
  int _playRequestId = 0;

  AudioPlayerService._() {
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  static AudioPlayerService get instance {
    _instance ??= AudioPlayerService._();
    return _instance!;
  }

  AudioPlayer get player => _player;
  List<SongModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  SongModel? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;
  bool get isPlaying => _player.playing;
  bool get shuffleEnabled => _shuffleEnabled;
  LoopMode get loopMode => _loopMode;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  Future<void> play(SongModel song, {List<SongModel>? queue}) async {
    final playId = ++_playRequestId;

    if (queue != null) {
      _queue = List.from(queue);
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _queue.insert(0, song);
        _currentIndex = 0;
      }
    } else {
      final existingIndex = _queue.indexWhere((s) => s.id == song.id);
      if (existingIndex >= 0) {
        _currentIndex = existingIndex;
      } else {
        _queue.add(song);
        _currentIndex = _queue.length - 1;
      }
    }

    await _player.stop();
    _isLoading = true;

    try {
      final streamUrl = await MusicService.instance.getStreamUrl(song.id);

      if (playId != _playRequestId) return;

      if (streamUrl == null || streamUrl.isEmpty) {
        _isLoading = false;
        return;
      }

      await _player.setUrl(streamUrl);

      if (playId != _playRequestId) return;

      _isLoading = false;
      await _player.play();
    } catch (e) {
      if (playId == _playRequestId) {
        _isLoading = false;
      }
      rethrow;
    }
  }

  Future<void> resume() async => _player.play();
  Future<void> pause() async => _player.pause();
  Future<void> stop() async => _player.stop();

  Future<void> seek(Duration position) async => _player.seek(position);

  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await play(_queue[_currentIndex]);
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = 0;
      await play(_queue[_currentIndex]);
    }
  }

  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      await play(_queue[_currentIndex]);
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = _queue.length - 1;
      await play(_queue[_currentIndex]);
    }
  }

  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      await play(_queue[_currentIndex]);
    }
  }

  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    if (_shuffleEnabled) {
      final current = currentSong;
      _queue.shuffle();
      if (current != null) {
        final newIndex = _queue.indexWhere((s) => s.id == current.id);
        if (newIndex > 0) {
          final temp = _queue[0];
          _queue[0] = _queue[newIndex];
          _queue[newIndex] = temp;
        }
        _currentIndex = 0;
      }
    }
  }

  void toggleLoop() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    _player.setLoopMode(_loopMode);
  }

  void setVolume(double volume) => _player.setVolume(volume);
  void setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> setQueue(List<SongModel> songs, {int startIndex = 0}) async {
    _queue = List.from(songs);
    if (startIndex >= 0 && startIndex < _queue.length) {
      _currentIndex = startIndex;
      await play(_queue[_currentIndex]);
    }
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex) {
        if (_currentIndex >= _queue.length) {
          _currentIndex = _queue.length - 1;
        }
      }
    }
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    _player.stop();
  }

  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
