import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'puzless.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL DEFAULT 'Jugador',
        total_xp INTEGER NOT NULL DEFAULT 0,
        level INTEGER NOT NULL DEFAULT 1,
        games_played INTEGER NOT NULL DEFAULT 0,
        games_won INTEGER NOT NULL DEFAULT 0,
        current_streak INTEGER NOT NULL DEFAULT 0,
        best_streak INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE game_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_type TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        score INTEGER NOT NULL DEFAULT 0,
        time_seconds INTEGER,
        won INTEGER NOT NULL DEFAULT 0,
        played_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_challenge (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        game_type TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        score INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert default profile
    await db.insert('user_profile', {
      'username': 'Jugador',
      'total_xp': 0,
      'level': 1,
      'games_played': 0,
      'games_won': 0,
      'current_streak': 0,
      'best_streak': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Insert default settings
    final defaults = {
      'dark_mode': 'false',
      'sound_enabled': 'true',
      'music_enabled': 'false',
      'haptic_enabled': 'true',
    };
    for (final entry in defaults.entries) {
      await db.insert('settings', {'key': entry.key, 'value': entry.value});
    }
  }

  // ── Profile ──

  Future<Map<String, dynamic>> getProfile() async {
    final db = await database;
    final results = await db.query('user_profile', limit: 1);
    return results.first;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    await db.update('user_profile', data);
  }

  Future<void> addXp(int xp) async {
    final db = await database;
    final profile = await getProfile();
    final totalXp = (profile['total_xp'] as int) + xp;
    final level = _calculateLevel(totalXp);
    await db.update('user_profile', {
      'total_xp': totalXp,
      'level': level,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  int _calculateLevel(int xp) {
    // Each level requires progressively more XP
    int level = 1;
    int required = 100;
    int accumulated = 0;
    while (accumulated + required <= xp) {
      accumulated += required;
      level++;
      required = (required * 1.3).toInt();
    }
    return level;
  }

  int xpForNextLevel(int totalXp) {
    int required = 100;
    int accumulated = 0;
    while (accumulated + required <= totalXp) {
      accumulated += required;
      required = (required * 1.3).toInt();
    }
    return accumulated + required;
  }

  int xpInCurrentLevel(int totalXp) {
    int required = 100;
    int accumulated = 0;
    while (accumulated + required <= totalXp) {
      accumulated += required;
      required = (required * 1.3).toInt();
    }
    return totalXp - accumulated;
  }

  int xpRequiredForCurrentLevel(int totalXp) {
    int required = 100;
    int accumulated = 0;
    while (accumulated + required <= totalXp) {
      accumulated += required;
      required = (required * 1.3).toInt();
    }
    return required;
  }

  // ── Game Stats ──

  Future<void> recordGame({
    required String gameType,
    required String difficulty,
    required int score,
    int? timeSeconds,
    required bool won,
  }) async {
    final db = await database;
    await db.insert('game_stats', {
      'game_type': gameType,
      'difficulty': difficulty,
      'score': score,
      'time_seconds': timeSeconds,
      'won': won ? 1 : 0,
      'played_at': DateTime.now().toIso8601String(),
    });

    final profile = await getProfile();
    final gamesPlayed = (profile['games_played'] as int) + 1;
    final gamesWon = (profile['games_won'] as int) + (won ? 1 : 0);
    int currentStreak = profile['current_streak'] as int;
    int bestStreak = profile['best_streak'] as int;

    if (won) {
      currentStreak++;
      if (currentStreak > bestStreak) bestStreak = currentStreak;
    } else {
      currentStreak = 0;
    }

    await updateProfile({
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
    });

    // Award XP
    final xp = won ? (score * 0.5 + 20).toInt() : 5;
    await addXp(xp);
  }

  Future<List<Map<String, dynamic>>> getStatsForGame(String gameType) async {
    final db = await database;
    return await db.query(
      'game_stats',
      where: 'game_type = ?',
      whereArgs: [gameType],
      orderBy: 'played_at DESC',
      limit: 50,
    );
  }

  Future<Map<String, dynamic>?> getBestScore(String gameType) async {
    final db = await database;
    final results = await db.query(
      'game_stats',
      where: 'game_type = ? AND won = 1',
      whereArgs: [gameType],
      orderBy: 'score DESC',
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  // ── Daily Challenge ──

  Future<Map<String, dynamic>?> getDailyChallenge(String date) async {
    final db = await database;
    final results = await db.query(
      'daily_challenge',
      where: 'date = ?',
      whereArgs: [date],
    );
    return results.isEmpty ? null : results.first;
  }

  Future<void> saveDailyChallenge({
    required String date,
    required String gameType,
    required String difficulty,
  }) async {
    final db = await database;
    await db.insert(
      'daily_challenge',
      {
        'date': date,
        'game_type': gameType,
        'difficulty': difficulty,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> completeDailyChallenge(String date, int score) async {
    final db = await database;
    await db.update(
      'daily_challenge',
      {
        'completed': 1,
        'score': score,
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> getCompletedChallengesCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_challenge WHERE completed = 1',
    );
    return result.first['count'] as int;
  }

  // ── Settings ──

  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    return results.isEmpty ? null : results.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
