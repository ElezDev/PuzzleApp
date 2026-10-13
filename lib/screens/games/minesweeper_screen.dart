import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class MinesweeperScreen extends StatefulWidget {
  const MinesweeperScreen({super.key});

  @override
  State<MinesweeperScreen> createState() => _MinesweeperScreenState();
}

class _Cell {
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int adjacent = 0;
}

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  String _difficulty = 'Fácil';
  late List<List<_Cell>> _grid;
  bool _minesPlaced = false;
  bool _gameOver = false;
  bool _recorded = false;
  int _flags = 0;
  int _revealed = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _timeText = '00:00';
  final Random _random = Random();

  int get _rows => _difficulty == 'Difícil' ? 10 : (_difficulty == 'Medio' ? 9 : 8);
  int get _cols => _rows;
  int get _mines => _difficulty == 'Difícil' ? 20 : (_difficulty == 'Medio' ? 14 : 10);

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

  void _startGame() {
    _grid = List.generate(
      _rows,
      (_) => List.generate(_cols, (_) => _Cell()),
    );
    _minesPlaced = false;
    _gameOver = false;
    _recorded = false;
    _flags = 0;
    _revealed = 0;
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

  bool _inBounds(int r, int c) => r >= 0 && r < _rows && c >= 0 && c < _cols;

  void _placeMines(int safeR, int safeC) {
    var placed = 0;
    while (placed < _mines) {
      final r = _random.nextInt(_rows);
      final c = _random.nextInt(_cols);
      if (_grid[r][c].isMine) continue;
      if (r == safeR && c == safeC) continue;
      _grid[r][c].isMine = true;
      placed++;
    }
    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        if (_grid[r][c].isMine) continue;
        _grid[r][c].adjacent = _countAdjacent(r, c);
      }
    }
    _minesPlaced = true;
  }

  int _countAdjacent(int r, int c) {
    var count = 0;
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = r + dr;
        final nc = c + dc;
        if (_inBounds(nr, nc) && _grid[nr][nc].isMine) count++;
      }
    }
    return count;
  }

  void _onTap(int r, int c) {
    if (_gameOver || _grid[r][c].isFlagged || _grid[r][c].isRevealed) return;
    if (!_minesPlaced) _placeMines(r, c);

    final provider = context.read<AppProvider>();

    if (_grid[r][c].isMine) {
      provider.sound.playError();
      _revealAllMines();
      _endGame(won: false);
      return;
    }

    provider.sound.playTap();
    setState(() => _floodReveal(r, c));
    _checkWin();
  }

  void _onLongPress(int r, int c) {
    if (_gameOver || _grid[r][c].isRevealed || !_minesPlaced) return;
    setState(() {
      _grid[r][c].isFlagged = !_grid[r][c].isFlagged;
      _flags += _grid[r][c].isFlagged ? 1 : -1;
    });
    context.read<AppProvider>().sound.playTap();
  }

  void _floodReveal(int r, int c) {
    if (!_inBounds(r, c)) return;
    final cell = _grid[r][c];
    if (cell.isRevealed || cell.isFlagged || cell.isMine) return;
    cell.isRevealed = true;
    _revealed++;
    if (cell.adjacent == 0) {
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          _floodReveal(r + dr, c + dc);
        }
      }
    }
  }

  void _revealAllMines() {
    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        if (_grid[r][c].isMine) _grid[r][c].isRevealed = true;
      }
    }
    setState(() {});
  }

  void _checkWin() {
    if (_revealed == _rows * _cols - _mines) {
      _endGame(won: true);
    } else {
      setState(() {});
    }
  }

  void _endGame({required bool won}) {
    if (_recorded) return;
    _recorded = true;
    _gameOver = true;
    _stopwatch.stop();
    _timer?.cancel();

    final provider = context.read<AppProvider>();
    if (won) provider.sound.playWin();

    final elapsed = _stopwatch.elapsed.inSeconds;
    final difficultyBonus = _difficulty == 'Difícil'
        ? 300
        : (_difficulty == 'Medio' ? 180 : 100);
    final timeBonus = max(0, 400 - elapsed * 2);
    final score = won ? difficultyBonus + timeBonus + 50 : max(0, _revealed * 5);

    provider.recordGame(
      gameType: 'minesweeper',
      difficulty: _difficulty,
      score: score,
      timeSeconds: elapsed,
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
          score: score,
          timeText: _timeText,
          gameTitle: strings.gameName('minesweeper'),
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

  Color _numberColor(int value) {
    switch (value) {
      case 1:
        return const Color(0xFF1976D2);
      case 2:
        return const Color(0xFF388E3C);
      case 3:
        return const Color(0xFFD32F2F);
      case 4:
        return const Color(0xFF7B1FA2);
      case 5:
        return const Color(0xFFF57C00);
      case 6:
        return const Color(0xFF0097A7);
      case 7:
        return const Color(0xFF2D2D3A);
      default:
        return const Color(0xFF616161);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.gameName('minesweeper')),
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
                    icon: Icons.flag_rounded,
                    label: strings.minesLabel(_mines - _flags),
                    color: AppTheme.error,
                  ),
                  _InfoChip(
                    icon: Icons.check_circle_rounded,
                    label: '$_revealed / ${_rows * _cols - _mines}',
                    color: AppTheme.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                strings.minesweeperHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 3.0;
                    final cellW =
                        (constraints.maxWidth - spacing * (_cols - 1)) / _cols;
                    final cellH =
                        (constraints.maxHeight - spacing * (_rows - 1)) / _rows;
                    final cell = min(cellW, cellH);
                    final boardW = cell * _cols + spacing * (_cols - 1);
                    final boardH = cell * _rows + spacing * (_rows - 1);
                    return Center(
                      child: SizedBox(
                        width: boardW,
                        height: boardH,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _cols,
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            mainAxisExtent: cell,
                          ),
                          itemCount: _rows * _cols,
                          itemBuilder: (context, index) {
                            final r = index ~/ _cols;
                            final c = index % _cols;
                            return _MineCell(
                              cell: _grid[r][c],
                              numberColor: _numberColor,
                              onTap: () => _onTap(r, c),
                              onLongPress: () => _onLongPress(r, c),
                            );
                          },
                        ),
                      ),
                    );
                  },
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

class _MineCell extends StatelessWidget {
  final _Cell cell;
  final Color Function(int) numberColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _MineCell({
    required this.cell,
    required this.numberColor,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;
    Color bg;
    if (cell.isRevealed) {
      bg = theme.scaffoldBackgroundColor;
      if (cell.isMine) {
        child = const Icon(Icons.dangerous_rounded,
            color: AppTheme.error, size: 20);
      } else if (cell.adjacent > 0) {
        child = FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${cell.adjacent}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: numberColor(cell.adjacent),
            ),
          ),
        );
      } else {
        child = const SizedBox.shrink();
      }
    } else {
      bg = theme.cardColor;
      child = cell.isFlagged
          ? const FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(Icons.flag_rounded,
                  color: AppTheme.error, size: 18),
            )
          : const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: cell.isRevealed
              ? null
              : Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
          boxShadow: cell.isRevealed
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Center(child: child),
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
