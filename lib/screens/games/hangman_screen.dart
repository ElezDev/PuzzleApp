import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class HangmanScreen extends StatefulWidget {
  const HangmanScreen({super.key, this.initialDifficulty});

  final String? initialDifficulty;

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> {
  String _difficulty = 'Fácil';
  late String _word;
  final Set<String> _guessed = {};
  int _wrong = 0;
  int _score = 0;
  bool _gameOver = false;

  static const _keyboardRows = [
    'QWERTYUIOP',
    'ASDFGHJKLÑ',
    'ZXCVBNM',
  ];

  static const _wordsEasy = [
    'CASA',
    'GATO',
    'LUNA',
    'MESA',
    'ROJO',
    'AGUA',
    'LIBRO',
    'PERRO',
    'CIELO',
    'NIEVE',
    'PLAYA',
    'TIGRE',
    'FUEGO',
    'NUBE',
  ];

  static const _wordsMedium = [
    'ESCUELA',
    'VENTANA',
    'JARDIN',
    'MUSICA',
    'CIUDAD',
    'CAMINO',
    'PASTEL',
    'PLANETA',
    'ANIMAL',
    'BOTELLA',
    'PELOTA',
    'VENTILADOR',
  ];

  static const _wordsHard = [
    'ELEFANTE',
    'MARIPOSA',
    'BIBLIOTECA',
    'CHOCOLATE',
    'TELESCOPIO',
    'MONTAÑA',
    'ARAÑA',
    'ESPAÑA',
    'CALABAZA',
    'DINOSAURIO',
  ];

  int get _maxWrong {
    switch (_difficulty) {
      case 'Fácil':
        return 8;
      case 'Difícil':
        return 5;
      default:
        return 6;
    }
  }

  List<String> get _wordBank {
    switch (_difficulty) {
      case 'Fácil':
        return _wordsEasy;
      case 'Difícil':
        return _wordsHard;
      default:
        return _wordsMedium;
    }
  }

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty ?? _difficulty;
    _startGame();
  }

  void _startGame() {
    final rand = Random();
    _word = _wordBank[rand.nextInt(_wordBank.length)];
    _guessed.clear();
    _wrong = 0;
    _score = 0;
    _gameOver = false;
    setState(() {});
  }

  bool get _won => _word.split('').every(_guessed.contains);

  void _onLetterTap(String letter) {
    if (_gameOver || _guessed.contains(letter)) return;

    final provider = context.read<AppProvider>();
    final correct = _word.contains(letter);

    setState(() {
      _guessed.add(letter);
      if (!correct) _wrong++;
    });

    if (correct) {
      provider.sound.playTap();
    } else {
      provider.sound.playError();
    }

    if (_won) {
      _finish(true);
    } else if (_wrong >= _maxWrong) {
      _finish(false);
    }
  }

  void _finish(bool won) {
    if (_gameOver) return;
    _gameOver = true;

    final provider = context.read<AppProvider>();
    final difficultyBonus = _difficulty == 'Fácil'
        ? 0
        : _difficulty == 'Medio'
            ? 20
            : 40;
    final remaining = _maxWrong - _wrong;
    _score = won
        ? _word.length * 10 + remaining * 15 + difficultyBonus
        : _word.split('').where(_guessed.contains).length * 5;

    if (won) {
      provider.sound.playWin();
    }

    provider.recordGame(
      gameType: 'hangman',
      difficulty: _difficulty,
      score: _score,
      won: won,
    );

    setState(() {});

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final strings = AppStrings.of(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameResultDialog(
          won: won,
          score: _score,
          gameTitle: strings.gameName('hangman'),
          onPlayAgain: () {
            Navigator.pop(context);
            _startGame();
          },
          onGoHome: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.gameName('hangman')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            DifficultySelector(
              selected: _difficulty,
              onChanged: (d) {
                setState(() => _difficulty = d);
                _startGame();
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(
                    icon: Icons.star_rounded,
                    label: strings.pointsShort(_score),
                    color: AppTheme.warning,
                  ),
                  _InfoChip(
                    icon: Icons.favorite_rounded,
                    label: strings.attemptsLeft(
                      (_maxWrong - _wrong).clamp(0, _maxWrong),
                    ),
                    color: AppTheme.error,
                  ),
                  _InfoChip(
                    icon: Icons.text_fields_rounded,
                    label: '${_word.length}',
                    color: AppTheme.primaryLight,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 12,
                    children: _word
                        .split('')
                        .map((letter) => _LetterBox(
                              letter: letter,
                              revealed: _guessed.contains(letter) ||
                                  _gameOver &&
                                      _wrong >= _maxWrong,
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            if (_gameOver && !_won)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  strings.wordWas(_word),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
              ),
            if (!_gameOver)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  strings.pickLetter,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: Column(
                children: _keyboardRows.map((row) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row.split('').map((letter) {
                        return _KeyButton(
                          letter: letter,
                          state: !_guessed.contains(letter)
                              ? _KeyState.idle
                              : _word.contains(letter)
                                  ? _KeyState.correct
                                  : _KeyState.wrong,
                          onTap: () => _onLetterTap(letter),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _KeyState { idle, correct, wrong }

class _KeyButton extends StatelessWidget {
  final String letter;
  final _KeyState state;
  final VoidCallback onTap;

  const _KeyButton({
    required this.letter,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground) = switch (state) {
      _KeyState.correct => (AppTheme.success, Colors.white),
      _KeyState.wrong => (AppTheme.error.withValues(alpha: 0.85), Colors.white),
      _KeyState.idle => (
          theme.cardColor,
          theme.textTheme.bodyLarge?.color ?? Colors.black,
        ),
    };

    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        width: 32,
        height: 42,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: state == _KeyState.idle ? onTap : null,
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterBox extends StatelessWidget {
  final String letter;
  final bool revealed;

  const _LetterBox({required this.letter, required this.revealed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = revealed
        ? (AppTheme.primaryLight)
        : theme.textTheme.bodyLarge?.color ?? Colors.black;

    return SizedBox(
      width: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            revealed ? letter : '',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
