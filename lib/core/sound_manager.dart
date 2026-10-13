import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal() {
    _initPlayers();
  }

  static const int _poolSize = 4;
  final List<AudioPlayer> _pool = [];
  int _poolIndex = 0;
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  bool _musicEnabled = false;
  String? _desiredMusic;
  String? _currentMusic;
  Future<void>? _musicTask;

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get musicEnabled => _musicEnabled;

  void setSoundEnabled(bool enabled) => _soundEnabled = enabled;
  void setHapticEnabled(bool enabled) => _hapticEnabled = enabled;

  void _initPlayers() {
    for (var i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      player.setPlayerMode(PlayerMode.lowLatency);
      _pool.add(player);
    }
    _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
  }

  Future<void> _play(String asset) async {
    if (!_soundEnabled) return;
    try {
      final player = _pool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _pool.length;
      await player.stop();
      await player.play(AssetSource('sounds/$asset'));
    } catch (_) {
      // Ignore playback errors (e.g. unsupported platform).
    }
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _currentMusic = null;
      _musicPlayer.stop();
    } else if (_desiredMusic != null) {
      _playMusic(_desiredMusic!);
    }
  }

  Future<void> _playMusic(String asset) {
    _desiredMusic = asset;
    _musicTask = _musicTask?.then((_) => _playMusicNow(asset)) ??
        _playMusicNow(asset);
    return _musicTask!;
  }

  Future<void> _playMusicNow(String asset) async {
    if (!_musicEnabled) return;
    try {
      if (_currentMusic == asset &&
          _musicPlayer.state == PlayerState.playing) {
        return;
      }
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/$asset'));
      _currentMusic = asset;
    } catch (_) {
      // Ignore playback errors.
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!_musicEnabled || _currentMusic == null) return;
    try {
      await _musicPlayer.resume();
    } catch (_) {}
  }

  Future<void> playMenuMusic() => _playMusic('music_menu.wav');

  Future<void> playGameMusic(String gameId) {
    final arcade = {'tetris', '2048', 'breakout'};
    return _playMusic(
      arcade.contains(gameId) ? 'music_arcade.wav' : 'music_game.wav',
    );
  }

  Future<void> stopMusic() async {
    _currentMusic = null;
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> playTap() async {
    if (_hapticEnabled) HapticFeedback.lightImpact();
    await _play('tap.wav');
  }

  Future<void> playSuccess() async {
    if (_hapticEnabled) HapticFeedback.mediumImpact();
    await _play('success.wav');
  }

  Future<void> playWin() async {
    if (_hapticEnabled) HapticFeedback.heavyImpact();
    await _play('win.wav');
  }

  Future<void> playError() async {
    if (_hapticEnabled) HapticFeedback.heavyImpact();
    await _play('error.wav');
  }

  Future<void> playCoin() async {
    if (_hapticEnabled) HapticFeedback.lightImpact();
    await _play('coin.wav');
  }

  void dispose() {
    for (final player in _pool) {
      player.dispose();
    }
    _pool.clear();
    _musicPlayer.dispose();
  }
}