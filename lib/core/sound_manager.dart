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

  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  void setSoundEnabled(bool enabled) => _soundEnabled = enabled;
  void setHapticEnabled(bool enabled) => _hapticEnabled = enabled;

  void _initPlayers() {
    for (var i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      player.setPlayerMode(PlayerMode.lowLatency);
      _pool.add(player);
    }
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
  }
}
