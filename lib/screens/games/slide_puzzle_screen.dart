import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class SlidePuzzleScreen extends StatefulWidget {
  const SlidePuzzleScreen({super.key});

  @override
  State<SlidePuzzleScreen> createState() => _SlidePuzzleScreenState();
}

class _SlidePuzzleScreenState extends State<SlidePuzzleScreen> {
  String _difficulty = 'Fácil';
  late List<int> _tiles;
  late int _gridSize;
  int _moves = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _timeText = '00:00';
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  int get _size {
    switch (_difficulty) {
      case 'Fácil':
        return 3;
      case 'Difícil':
        return 5;
      default:
        return 4;
    }
  }

  void _startGame() {
    _gridSize = _size;
    final total = _gridSize * _gridSize;
    _tiles = List.generate(total, (i) => i); // 0 = empty
    _shuffle();
    _moves = 0;
    _gameOver = false;
    _timeText = '00:00';
    _stopwatch.reset();
    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final elapsed = _stopwatch.elapsed;
      setState(() {
        _timeText =
            '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
    setState(() {});
  }

  void _shuffle() {
    final rand = Random();
    // Do random valid moves to ensure solvability
    int emptyIdx = 0;
    for (int i = 0; i < _gridSize * 200; i++) {
      final neighbors = _getMovableNeighbors(emptyIdx);
      final pick = neighbors[rand.nextInt(neighbors.length)];
      _tiles[emptyIdx] = _tiles[pick];
      _tiles[pick] = 0;
      emptyIdx = pick;
    }
  }

  List<int> _getMovableNeighbors(int emptyIdx) {
    final row = emptyIdx ~/ _gridSize;
    final col = emptyIdx % _gridSize;
    final neighbors = <int>[];
    if (row > 0) neighbors.add((row - 1) * _gridSize + col);
    if (row < _gridSize - 1) neighbors.add((row + 1) * _gridSize + col);
    if (col > 0) neighbors.add(row * _gridSize + (col - 1));
    if (col < _gridSize - 1) neighbors.add(row * _gridSize + (col + 1));
    return neighbors;
  }

  void _onTileTap(int index) {
    if (_gameOver) return;
    final emptyIdx = _tiles.indexOf(0);
    final neighbors = _getMovableNeighbors(emptyIdx);

    if (neighbors.contains(index)) {
      final provider = context.read<AppProvider>();
      provider.sound.playTap();

      setState(() {
        _tiles[emptyIdx] = _tiles[index];
        _tiles[index] = 0;
        _moves++;
      });

      if (_isSolved()) {
        _stopwatch.stop();
        _timer?.cancel();
        _gameOver = true;
        _onWin();
      }
    }
  }

  bool _isSolved() {
    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) return false;
    }
    return _tiles.last == 0;
  }

  void _onWin() {
    final provider = context.read<AppProvider>();
    provider.sound.playWin();

    final timeBonus = max(0, 500 - _stopwatch.elapsed.inSeconds);
    final moveBonus = max(0, (_gridSize * _gridSize * 3) - _moves) * 3;
    final score = 50 + timeBonus + moveBonus;

    provider.recordGame(
      gameType: 'slide_puzzle',
      difficulty: _difficulty,
      score: score,
      timeSeconds: _stopwatch.elapsed.inSeconds,
      won: true,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameResultDialog(
          won: true,
          score: score,
          timeText: _timeText,
          gameTitle: 'Deslizar',
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

  Color _getTileColor(int value) {
    if (value == 0) return Colors.transparent;
    final hue = (value * 360 / (_gridSize * _gridSize)).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.6, 0.6).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deslizar'),
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
                    icon: Icons.timer_rounded,
                    label: _timeText,
                    color: AppTheme.primaryLight,
                  ),
                  _InfoChip(
                    icon: Icons.swap_horiz_rounded,
                    label: '$_moves movimientos',
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridSize,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: _tiles.length,
                      itemBuilder: (context, index) {
                        final value = _tiles[index];
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () => _onTileTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _getTileColor(value),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '$value',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
