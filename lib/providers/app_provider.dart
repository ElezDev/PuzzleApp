import 'package:flutter/material.dart';
import '../core/database_helper.dart';
import '../core/sound_manager.dart';
import '../models/shop_item.dart';
import '../models/app_background.dart';
import '../models/game_info.dart';

class AppProvider extends ChangeNotifier {
  static const String globalBackgroundSlot = 'global';

  final DatabaseHelper _db = DatabaseHelper();
  final SoundManager _sound = SoundManager();

  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _musicEnabled = false;
  bool _hapticEnabled = true;
  String _languageCode = 'system';
  Map<String, dynamic> _profile = {};
  List<String> _purchases = [];
  String _equippedAvatar = ShopItem.defaultAvatar.id;
  final Map<String, String> _backgrounds = {};
  bool _isLoaded = false;

  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get hapticEnabled => _hapticEnabled;
  String get languageCode => _languageCode;
  Locale? get locale => _languageCode == 'system' ? null : Locale(_languageCode);
  Map<String, dynamic> get profile => _profile;
  bool get isLoaded => _isLoaded;
  DatabaseHelper get db => _db;
  SoundManager get sound => _sound;
  List<String> get purchases => List.unmodifiable(_purchases);

  int get level => (_profile['level'] as int?) ?? 1;
  int get totalXp => (_profile['total_xp'] as int?) ?? 0;
  int get coins => (_profile['coins'] as int?) ?? 0;
  int get gamesPlayed => (_profile['games_played'] as int?) ?? 0;
  int get gamesWon => (_profile['games_won'] as int?) ?? 0;
  int get currentStreak => (_profile['current_streak'] as int?) ?? 0;
  int get bestStreak => (_profile['best_streak'] as int?) ?? 0;
  String get username => (_profile['username'] as String?) ?? 'Jugador';

  ShopItem get equippedAvatar => ShopItem.byId(_equippedAvatar);

  /// The background used across the whole app (fallback for every screen).
  AppBackground get globalBackground => AppBackground.byId(
        _backgrounds[globalBackgroundSlot] ??
            AppBackground.defaultBackground.id,
      );

  /// The background equipped specifically for [slot], or null when the slot
  /// should fall back to the global background.
  AppBackground? backgroundFor(String slot) {
    if (slot == globalBackgroundSlot) return globalBackground;
    final id = _backgrounds[slot];
    return id == null ? null : AppBackground.byId(id);
  }

  String resolvedBackgroundId(String slot) {
    if (slot == globalBackgroundSlot) return globalBackground.id;
    return _backgrounds[slot] ?? globalBackground.id;
  }

  bool isPurchased(String itemId) =>
      itemId == ShopItem.defaultAvatar.id ||
      itemId == AppBackground.defaultBackground.id ||
      _purchases.contains(itemId);

  bool isEquipped(String itemId) => _equippedAvatar == itemId;

  bool isBackgroundEquipped(String slot, String itemId) =>
      resolvedBackgroundId(slot) == itemId;

  bool isBackgroundInherited(String slot, String itemId) =>
      slot != globalBackgroundSlot &&
      _backgrounds[slot] == null &&
      globalBackground.id == itemId;

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

    final languageCode = await _db.getSetting('language_code');
    _languageCode = (languageCode == null || languageCode.isEmpty)
        ? 'system'
        : languageCode;

    _profile = await _db.getProfile();
    _purchases = await _db.getPurchases();

    final avatar = await _db.getSetting('equipped_avatar');
    _equippedAvatar = (avatar == null || avatar.isEmpty)
        ? ShopItem.defaultAvatar.id
        : avatar;

    _backgrounds.clear();
    final globalBg = await _db.getSetting('equipped_background_global');
    final legacyBg = await _db.getSetting('equipped_background');
    _backgrounds[globalBackgroundSlot] =
        (globalBg != null && globalBg.isNotEmpty)
            ? globalBg
            : ((legacyBg != null && legacyBg.isNotEmpty)
                ? legacyBg
                : AppBackground.defaultBackground.id);
    for (final game in GameInfo.allGames) {
      final value = await _db.getSetting('equipped_background_${game.id}');
      if (value != null && value.isNotEmpty) {
        _backgrounds[game.id] = value;
      }
    }

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

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await _db.setSetting('language_code', code);
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

  Future<bool> purchase(String itemId, int price) async {
    if (isPurchased(itemId)) return true;
    final success = await _db.spendCoins(price);
    if (!success) return false;
    await _db.recordPurchase(itemId);
    _profile = await _db.getProfile();
    _purchases = await _db.getPurchases();
    notifyListeners();
    return true;
  }

  Future<bool> purchaseItem(ShopItem item) => purchase(item.id, item.price);

  Future<bool> purchaseBackground(AppBackground item) =>
      purchase(item.id, item.price);

  Future<void> equipAvatar(String itemId) async {
    if (!isPurchased(itemId)) return;
    _equippedAvatar = itemId;
    await _db.setSetting('equipped_avatar', itemId);
    notifyListeners();
  }

  /// Equips [itemId] to [slot]. Pass null to clear the override on a game
  /// slot so it falls back to the global background.
  Future<void> equipBackground(String slot, String? itemId) async {
    if (itemId == null) {
      _backgrounds.remove(slot);
      await _db.setSetting('equipped_background_$slot', '');
      notifyListeners();
      return;
    }
    if (!isPurchased(itemId)) return;
    _backgrounds[slot] = itemId;
    await _db.setSetting('equipped_background_$slot', itemId);
    notifyListeners();
  }
}
