import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/game_info.dart';
import 'games/tic_tac_toe_screen.dart';
import 'games/memory_screen.dart';
import 'games/slide_puzzle_screen.dart';
import 'games/pattern_screen.dart';
import 'games/sudoku_screen.dart';
import 'games/color_match_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  bool _isCompleted = false;
  int _challengeScore = 0;
  late String _todayDate;
  late GameInfo _todayGame;
  late String _todayDifficulty;

  @override
  void initState() {
    super.initState();
    _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _generateDailyChallenge();
    _loadChallenge();
  }

  void _generateDailyChallenge() {
    // Use date as seed for consistent daily challenge
    final seed = _todayDate.hashCode;
    final rand = Random(seed);
    final gameIdx = rand.nextInt(GameInfo.allGames.length);
    _todayGame = GameInfo.allGames[gameIdx];

    final difficulties = ['Fácil', 'Medio', 'Difícil'];
    _todayDifficulty = difficulties[rand.nextInt(3)];
  }

  Future<void> _loadChallenge() async {
    final provider = context.read<AppProvider>();
    final db = provider.db;

    await db.saveDailyChallenge(
      date: _todayDate,
      gameType: _todayGame.id,
      difficulty: _todayDifficulty,
    );

    final challenge = await db.getDailyChallenge(_todayDate);
    if (challenge != null) {
      setState(() {
        _isCompleted = challenge['completed'] == 1;
        _challengeScore = challenge['score'] as int;
      });
    }
  }

  void _playChallenge() {
    Widget screen;
    switch (_todayGame.id) {
      case 'tic_tac_toe':
        screen = const TicTacToeScreen();
      case 'memory':
        screen = const MemoryScreen();
      case 'slide_puzzle':
        screen = const SlidePuzzleScreen();
      case 'pattern':
        screen = const PatternScreen();
      case 'sudoku':
        screen = const SudokuScreen();
      case 'color_match':
        screen = const ColorMatchScreen();
      default:
        return;
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen))
        .then((_) => _loadChallenge());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desafío Diario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Date
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es').format(DateTime.now()),
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Challenge card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_todayGame.color, _todayGame.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _todayGame.color.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _todayGame.icon,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _todayGame.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Dificultad: $_todayDifficulty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _todayGame.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status
              if (_isCompleted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.success, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        '¡Desafío completado!',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Puntuación: $_challengeScore',
                        style: TextStyle(
                          color: AppTheme.success.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Play button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _playChallenge,
                  icon: Icon(_isCompleted
                      ? Icons.replay_rounded
                      : Icons.play_arrow_rounded),
                  label:
                      Text(_isCompleted ? 'Jugar de nuevo' : '¡Jugar ahora!'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
