import 'package:flutter/material.dart';
import '../core/database_helper.dart';
import '../core/sound_manager.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final SoundManager _sound = SoundManager();

  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _musicEnabled = false;
  bool _hapticEnabled = true;
  Map<String, dynamic> _profile = {};
  bool _isLoaded = false;

  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get hapticEnabled => _hapticEnabled;
  Map<String, dynamic> get profile => _profile;
  bool get isLoaded => _isLoaded;
  DatabaseHelper get db => _db;
  SoundManager get sound => _sound;

  int get level => (_profile['level'] as int?) ?? 1;
  int get totalXp => (_profile['total_xp'] as int?) ?? 0;
  int get gamesPlayed => (_profile['games_played'] as int?) ?? 0;
  int get gamesWon => (_profile['games_won'] as int?) ?? 0;
  int get currentStreak => (_profile['current_streak'] as int?) ?? 0;
  int get bestStreak => (_profile['best_streak'] as int?) ?? 0;
  String get username => (_profile['username'] as String?) ?? 'Jugador';

  double get levelProgress {
    final current = _db.xpInCurrentLevel(totalXp);
    final required = _db.xpRequiredForCurrentLevel(totalXp);
    return required > 0 ? current / required : 0;
  }

  Future<void> initialize() async {
    final darkMode = await _db.getSetting('dark_mode');
    _isDarkMode = darkMode == 'true';

    final sound = await _db.getSetting('sound_enabled');
    _soundEnabled = sound != 'false';
    _sound.setSoundEnabled(_soundEnabled);

    final music = await _db.getSetting('music_enabled');
    _musicEnabled = music == 'true';

    final haptic = await _db.getSetting('haptic_enabled');
    _hapticEnabled = haptic != 'false';
    _sound.setHapticEnabled(_hapticEnabled);

    _profile = await _db.getProfile();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _db.setSetting('dark_mode', _isDarkMode.toString());
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    _sound.setSoundEnabled(_soundEnabled);
    await _db.setSetting('sound_enabled', _soundEnabled.toString());
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    await _db.setSetting('music_enabled', _musicEnabled.toString());
    notifyListeners();
  }

  Future<void> toggleHaptic() async {
    _hapticEnabled = !_hapticEnabled;
    _sound.setHapticEnabled(_hapticEnabled);
    await _db.setSetting('haptic_enabled', _hapticEnabled.toString());
    notifyListeners();
  }

  Future<void> recordGame({
    required String gameType,
    required String difficulty,
    required int score,
    int? timeSeconds,
    required bool won,
  }) async {
    await _db.recordGame(
      gameType: gameType,
      difficulty: difficulty,
      score: score,
      timeSeconds: timeSeconds,
      won: won,
    );
    _profile = await _db.getProfile();
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    _profile = await _db.getProfile();
    notifyListeners();
  }

  Future<void> updateUsername(String name) async {
    await _db.updateProfile({'username': name});
    _profile = await _db.getProfile();
    notifyListeners();
  }
}
