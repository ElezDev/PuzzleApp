import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class ColorMatchScreen extends StatefulWidget {
  const ColorMatchScreen({super.key});

  @override
  State<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends State<ColorMatchScreen>
    with SingleTickerProviderStateMixin {
  String _difficulty = 'Fácil';
  int _score = 0;
  int _lives = 3;
  int _round = 0;
  bool _gameOver = false;
  late String _displayedWord;
  late Color _displayedColor;
  late List<Color> _options;
  late int _correctIndex;
  Timer? _roundTimer;
  double _timeLeft = 1.0;
  late AnimationController _shakeController;

  static const _colorNames = [
    'Rojo',
    'Azul',
    'Verde',
    'Amarillo',
    'Morado',
    'Naranja',
    'Rosa',
    'Cian',
  ];

  static const _colors = [
    Color(0xFFFF4444),
    Color(0xFF4488FF),
    Color(0xFF44CC44),
    Color(0xFFFFCC00),
    Color(0xFF9944FF),
    Color(0xFFFF8800),
    Color(0xFFFF66AA),
    Color(0xFF00CCCC),
  ];

  int get _timeMs {
    switch (_difficulty) {
      case 'Fácil':
        return 5000;
      case 'Difícil':
        return 2000;
      default:
        return 3000;
    }
  }

  int get _optionCount {
    switch (_difficulty) {
      case 'Fácil':
        return 2;
      case 'Difícil':
        return 4;
      default:
        return 3;
    }
  }

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _startGame();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startGame() {
    _score = 0;
    _lives = 3;
    _round = 0;
    _gameOver = false;
    _nextRound();
  }

  void _nextRound() {
    _round++;
    final rand = Random();

    // Pick a random word (color name)
    final wordIndex = rand.nextInt(_colorNames.length);
    _displayedWord = _colorNames[wordIndex];

    // Pick a different color for the text (the trick)
    int textColorIndex;
    do {
      textColorIndex = rand.nextInt(_colors.length);
    } while (textColorIndex == wordIndex);
    _displayedColor = _colors[textColorIndex];

    // The correct answer is the COLOR of the text, not the word
    _correctIndex = 0;
    _options = [];

    final usedIndices = <int>{textColorIndex};
    _options.add(_colors[textColorIndex]);

    while (_options.length < _optionCount) {
      final idx = rand.nextInt(_colors.length);
      if (!usedIndices.contains(idx)) {
        usedIndices.add(idx);
        _options.add(_colors[idx]);
      }
    }

    // Shuffle and track correct
    final correctColor = _options[0];
    _options.shuffle(rand);
    _correctIndex = _options.indexOf(correctColor);

    _timeLeft = 1.0;
    _roundTimer?.cancel();

    const tickMs = 50;
    _roundTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeLeft -= tickMs / _timeMs;
      });
      if (_timeLeft <= 0) {
        timer.cancel();
        _onWrong();
      }
    });

    setState(() {});
  }

  void _onOptionTap(int index) {
    if (_gameOver) return;

    final provider = context.read<AppProvider>();

    if (index == _correctIndex) {
      provider.sound.playSuccess();
      _score += (10 + (_timeLeft * 20).toInt());
      _roundTimer?.cancel();
      setState(() {});
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted || _gameOver) return;
        _nextRound();
      });
    } else {
      _onWrong();
    }
  }

  void _onWrong() {
    final provider = context.read<AppProvider>();
    provider.sound.playError();
    _shakeController.forward(from: 0);
    _lives--;
    _roundTimer?.cancel();

    if (_lives <= 0) {
      _gameOver = true;
      provider.recordGame(
        gameType: 'color_match',
        difficulty: _difficulty,
        score: _score,
        won: _round > 5,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameResultDialog(
            won: _round > 5,
            score: _score,
            gameTitle: 'Color Match - Ronda $_round',
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
    } else {
      setState(() {});
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || _gameOver) return;
        _nextRound();
      });
    }
  }

  String _getColorName(Color color) {
    final idx = _colors.indexOf(color);
    return idx >= 0 ? _colorNames[idx] : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Match'),
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
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(
                    icon: Icons.star_rounded,
                    label: '$_score pts',
                    color: AppTheme.warning,
                  ),
                  _InfoChip(
                    icon: Icons.layers_rounded,
                    label: 'Ronda $_round',
                    color: AppTheme.primaryLight,
                  ),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 20,
                          color: i < _lives ? AppTheme.error : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Timer bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _timeLeft.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppTheme.error.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(
                    _timeLeft > 0.3 ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Instruction
            Text(
              '¿De qué COLOR está escrita la palabra?',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            // Display word
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (_, child) {
                    final offset = sin(_shakeController.value * 4 * pi) * 10;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Text(
                    _displayedWord,
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: _displayedColor,
                    ),
                  ),
                ),
              ),
            ),
            // Options
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(_options.length, (i) {
                  return GestureDetector(
                    onTap: () => _onOptionTap(i),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _options[i],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _options[i].withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getColorName(_options[i]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
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
