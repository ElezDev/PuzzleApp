import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  String _difficulty = 'Fácil';
  List<int> _board = List<int>.filled(16, 0);
  int _score = 0;
  bool _reachedGoal = false;
  bool _gameOver = false;
  bool _recorded = false;
  final Random _random = Random();

  int get _goal {
    switch (_difficulty) {
      case 'Difícil':
        return 2048;
      case 'Medio':
        return 1024;
      default:
        return 512;
    }
  }

  int get _bestTile => _board.isEmpty ? 0 : _board.reduce(max);

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _board = List<int>.filled(16, 0);
      _score = 0;
      _reachedGoal = false;
      _gameOver = false;
      _recorded = false;
      _addRandomTile();
      _addRandomTile();
    });
  }

  void _addRandomTile() {
    final empty = <int>[];
    for (var i = 0; i < 16; i++) {
      if (_board[i] == 0) empty.add(i);
    }
    if (empty.isEmpty) return;
    final idx = empty[_random.nextInt(empty.length)];
    _board[idx] = _random.nextDouble() < 0.9 ? 2 : 4;
  }

  List<int> _extract(String dir, int i) {
    switch (dir) {
      case 'left':
        return [for (var j = 0; j < 4; j++) _board[i * 4 + j]];
      case 'right':
        return [for (var j = 3; j >= 0; j--) _board[i * 4 + j]];
      case 'up':
        return [for (var j = 0; j < 4; j++) _board[j * 4 + i]];
      default: // down
        return [for (var j = 3; j >= 0; j--) _board[j * 4 + i]];
    }
  }

  void _writeInto(List<int> target, String dir, int i, List<int> line) {
    switch (dir) {
      case 'left':
        for (var j = 0; j < 4; j++) {
          target[i * 4 + j] = line[j];
        }
        break;
      case 'right':
        for (var j = 0; j < 4; j++) {
          target[i * 4 + (3 - j)] = line[j];
        }
        break;
      case 'up':
        for (var j = 0; j < 4; j++) {
          target[j * 4 + i] = line[j];
        }
        break;
      default: // down
        for (var j = 0; j < 4; j++) {
          target[(3 - j) * 4 + i] = line[j];
        }
    }
  }

  List<int> _slide(List<int> line, void Function(int) onMerge) {
    final values = line.where((v) => v != 0).toList();
    final result = <int>[];
    var i = 0;
    while (i < values.length) {
      if (i + 1 < values.length && values[i] == values[i + 1]) {
        final merged = values[i] * 2;
        result.add(merged);
        onMerge(merged);
        i += 2;
      } else {
        result.add(values[i]);
        i++;
      }
    }
    while (result.length < 4) {
      result.add(0);
    }
    return result;
  }

  void _move(String dir) {
    if (_gameOver) return;

    final next = List<int>.filled(16, 0);
    var gained = 0;
    for (var i = 0; i < 4; i++) {
      final line = _extract(dir, i);
      final slid = _slide(line, (v) => gained += v);
      _writeInto(next, dir, i, slid);
    }

    if (listEquals(next, _board)) return;

    setState(() {
      _board = next;
      _score += gained;
      _addRandomTile();
    });

    if (gained > 0) {
      context.read<AppProvider>().sound.playTap();
    }

    _checkState();
  }

  void _checkState() {
    if (!_reachedGoal && _bestTile >= _goal) {
      _reachedGoal = true;
      if (!_recorded) {
        _recorded = true;
        _recordGame(won: true);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.of(context).goalLabel(_goal)} ✓'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.read<AppProvider>().sound.playWin();
    }

    if (_isGameOver()) {
      _gameOver = true;
      if (!_recorded) {
        _recorded = true;
        _recordGame(won: false);
      }
      _showResult();
    }
  }

  bool _isGameOver() {
    for (var i = 0; i < 16; i++) {
      if (_board[i] == 0) return false;
    }
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        final v = _board[r * 4 + c];
        if (c < 3 && _board[r * 4 + c + 1] == v) return false;
        if (r < 3 && _board[(r + 1) * 4 + c] == v) return false;
      }
    }
    return true;
  }

  void _recordGame({required bool won}) {
    context.read<AppProvider>().recordGame(
          gameType: '2048',
          difficulty: _difficulty,
          score: _score,
          won: won,
        );
  }

  void _showResult() {
    final strings = AppStrings.of(context);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameResultDialog(
          won: _reachedGoal,
          score: _score,
          gameTitle: strings.gameName('2048'),
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

  Color _tileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0xFF3C3A32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.gameName('2048')),
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
                    icon: Icons.grid_on_rounded,
                    label: strings.bestTileLabel(_bestTile),
                    color: AppTheme.primaryLight,
                  ),
                  _InfoChip(
                    icon: Icons.flag_rounded,
                    label: '$_goal',
                    color: AppTheme.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                strings.game2048Hint,
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onHorizontalDragEnd: (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v > 0) {
                      _move('right');
                    } else if (v < 0) {
                      _move('left');
                    }
                  },
                  onVerticalDragEnd: (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v > 0) {
                      _move('down');
                    } else if (v < 0) {
                      _move('up');
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: List.generate(4, (r) {
                          return Expanded(
                            child: Row(
                              children: List.generate(4, (c) {
                                final value = _board[r * 4 + c];
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: _Tile(
                                      value: value,
                                      color: _tileColor(value),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
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
                  label: Text(strings.restart),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final int value;
  final Color color;

  const _Tile({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == 0;
    final textColor = value <= 4
        ? const Color(0xFF776E65)
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: isEmpty
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
            : color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: value == 0
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.all(4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  ),
                ),
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
