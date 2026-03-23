import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class PatternScreen extends StatefulWidget {
  const PatternScreen({super.key});

  @override
  State<PatternScreen> createState() => _PatternScreenState();
}

class _PatternScreenState extends State<PatternScreen> {
  String _difficulty = 'Fácil';
  final List<int> _sequence = [];
  final List<int> _playerInput = [];
  int _currentShowIndex = -1;
  bool _isShowing = false;
  bool _canTap = false;
  int _round = 0;
  int _score = 0;
  bool _gameOver = false;

  static const _buttonColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B9D),
    Color(0xFF4ECDC4),
    Color(0xFFFFBE76),
    Color(0xFF45B7D1),
    Color(0xFFFF6B6B),
    Color(0xFFA29BFE),
    Color(0xFF55E6C1),
    Color(0xFFFF9FF3),
  ];

  int get _buttonCount {
    switch (_difficulty) {
      case 'Fácil':
        return 4;
      case 'Difícil':
        return 9;
      default:
        return 6;
    }
  }

  int get _showSpeed {
    switch (_difficulty) {
      case 'Fácil':
        return 700;
      case 'Difícil':
        return 400;
      default:
        return 550;
    }
  }

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _sequence.clear();
    _playerInput.clear();
    _round = 0;
    _score = 0;
    _gameOver = false;
    _nextRound();
  }

  void _nextRound() {
    _round++;
    _playerInput.clear();
    _sequence.add(Random().nextInt(_buttonCount));
    _showSequence();
  }

  Future<void> _showSequence() async {
    setState(() {
      _isShowing = true;
      _canTap = false;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() => _currentShowIndex = _sequence[i]);
      await Future.delayed(Duration(milliseconds: _showSpeed));
      if (!mounted) return;
      setState(() => _currentShowIndex = -1);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted) return;
    setState(() {
      _isShowing = false;
      _canTap = true;
    });
  }

  void _onButtonTap(int index) {
    if (!_canTap || _gameOver) return;

    final provider = context.read<AppProvider>();
    provider.sound.playTap();

    _playerInput.add(index);
    final currentIdx = _playerInput.length - 1;

    setState(() => _currentShowIndex = index);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _currentShowIndex = -1);
    });

    if (_playerInput[currentIdx] != _sequence[currentIdx]) {
      // Wrong
      _canTap = false;
      _gameOver = true;
      provider.sound.playError();

      provider.recordGame(
        gameType: 'pattern',
        difficulty: _difficulty,
        score: _score,
        won: _round > 3,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameResultDialog(
            won: _round > 3,
            score: _score,
            gameTitle: 'Patrones - Ronda $_round',
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
    } else if (_playerInput.length == _sequence.length) {
      // Completed round
      provider.sound.playSuccess();
      _score += _round * 15;
      setState(() {});

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted || _gameOver) return;
        _nextRound();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cols = _buttonCount <= 4 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrones'),
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
            const SizedBox(height: 16),
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(
                    icon: Icons.layers_rounded,
                    label: 'Ronda $_round',
                    color: AppTheme.primaryLight,
                  ),
                  _InfoChip(
                    icon: Icons.star_rounded,
                    label: '$_score pts',
                    color: AppTheme.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isShowing
                    ? 'Observa la secuencia...'
                    : (_canTap ? 'Tu turno - repite la secuencia' : ''),
                key: ValueKey('$_isShowing$_canTap'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Progress dots
            if (_canTap)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_sequence.length, (i) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _playerInput.length
                          ? AppTheme.success
                          : theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  );
                }),
              ),
            const SizedBox(height: 24),
            // Buttons
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _buttonCount,
                    itemBuilder: (context, index) {
                      final isActive = _currentShowIndex == index;
                      final color = _buttonColors[index % _buttonColors.length];
                      return GestureDetector(
                        onTap: () => _onButtonTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isActive
                                ? color
                                : color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reiniciar'),
                ),
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
