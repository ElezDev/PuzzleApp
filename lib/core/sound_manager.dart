import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  void setSoundEnabled(bool enabled) => _soundEnabled = enabled;
  void setHapticEnabled(bool enabled) => _hapticEnabled = enabled;

  Future<void> playTap() async {
    if (_hapticEnabled) HapticFeedback.lightImpact();
  }

  Future<void> playSuccess() async {
    if (_hapticEnabled) HapticFeedback.mediumImpact();
  }

  Future<void> playWin() async {
    if (_hapticEnabled) HapticFeedback.heavyImpact();
  }

  Future<void> playError() async {
    if (_hapticEnabled) HapticFeedback.heavyImpact();
  }

  void dispose() {
    _sfxPlayer.dispose();
  }
}
