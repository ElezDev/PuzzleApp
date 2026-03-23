import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  String _difficulty = 'Fácil';
  late List<List<int>> _board;
  late List<List<int>> _solution;
  late List<List<bool>> _fixed;
  int? _selectedRow;
  int? _selectedCol;
  int _errors = 0;
  final int _maxErrors = 3;
  bool _gameOver = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _timeText = '00:00';

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

  int get _removeCount {
    switch (_difficulty) {
      case 'Fácil':
        return 30;
      case 'Difícil':
        return 50;
      default:
        return 40;
    }
  }

  void _startGame() {
    _solution = _generateSudoku();
    _board = _solution.map((r) => List<int>.from(r)).toList();
    _fixed = List.generate(9, (_) => List.filled(9, true));

    final rand = Random();
    int removed = 0;
    while (removed < _removeCount) {
      final r = rand.nextInt(9);
      final c = rand.nextInt(9);
      if (_board[r][c] != 0) {
        _board[r][c] = 0;
        _fixed[r][c] = false;
        removed++;
      }
    }

    _selectedRow = null;
    _selectedCol = null;
    _errors = 0;
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

  List<List<int>> _generateSudoku() {
    final board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board);
    return board;
  }

  bool _fillBoard(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          final nums = List.generate(9, (i) => i + 1)..shuffle(Random());
          for (final n in nums) {
            if (_isValid(board, r, c, n)) {
              board[r][c] = n;
              if (_fillBoard(board)) return true;
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }
    final boxR = (row ~/ 3) * 3;
    final boxC = (col ~/ 3) * 3;
    for (int r = boxR; r < boxR + 3; r++) {
      for (int c = boxC; c < boxC + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }
    return true;
  }

  void _onCellTap(int row, int col) {
    if (_gameOver || _fixed[row][col]) return;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _onNumberTap(int num) {
    if (_selectedRow == null || _selectedCol == null || _gameOver) return;

    final provider = context.read<AppProvider>();
    provider.sound.playTap();

    setState(() {
      _board[_selectedRow!][_selectedCol!] = num;
    });

    if (num != _solution[_selectedRow!][_selectedCol!]) {
      provider.sound.playError();
      _errors++;
      if (_errors >= _maxErrors) {
        _gameOver = true;
        _stopwatch.stop();
        _timer?.cancel();

        provider.recordGame(
          gameType: 'sudoku',
          difficulty: _difficulty,
          score: 0,
          timeSeconds: _stopwatch.elapsed.inSeconds,
          won: false,
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          final strings = AppStrings.of(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => GameResultDialog(
              won: false,
              score: 0,
              timeText: _timeText,
              gameTitle: strings.gameName('sudoku'),
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
      setState(() {});
    } else {
      // Check if complete
      bool complete = true;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (_board[r][c] != _solution[r][c]) {
            complete = false;
            break;
          }
        }
        if (!complete) break;
      }

      if (complete) {
        _gameOver = true;
        _stopwatch.stop();
        _timer?.cancel();
        provider.sound.playWin();

        final timeBonus = max(0, 600 - _stopwatch.elapsed.inSeconds);
        final errorBonus = (_maxErrors - _errors) * 50;
        final score = 100 + timeBonus + errorBonus;

        provider.recordGame(
          gameType: 'sudoku',
          difficulty: _difficulty,
          score: score,
          timeSeconds: _stopwatch.elapsed.inSeconds,
          won: true,
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          final strings = AppStrings.of(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => GameResultDialog(
              won: true,
              score: score,
              timeText: _timeText,
              gameTitle: strings.gameName('sudoku'),
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
    }
  }

  void _onErase() {
    if (_selectedRow == null || _selectedCol == null || _gameOver) return;
    if (_fixed[_selectedRow!][_selectedCol!]) return;
    setState(() {
      _board[_selectedRow!][_selectedCol!] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.gameName('sudoku')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            DifficultySelector(
              selected: _difficulty,
              onChanged: (d) {
                setState(() => _difficulty = d);
                _startGame();
              },
            ),
            const SizedBox(height: 8),
            // Info
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
                    icon: Icons.close_rounded,
                    label: strings.errorsLabel(_errors, _maxErrors),
                    color: AppTheme.error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Board
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                      ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        final row = index ~/ 9;
                        final col = index % 9;
                        final value = _board[row][col];
                        final isFixed = _fixed[row][col];
                        final isSelected =
                            _selectedRow == row && _selectedCol == col;
                        final isHighlighted =
                            _selectedRow == row || _selectedCol == col;
                        final isError = value != 0 &&
                            !isFixed &&
                            value != _solution[row][col];

                        return GestureDetector(
                          onTap: () => _onCellTap(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryLight.withValues(alpha: 0.2)
                                  : isHighlighted
                                      ? AppTheme.primaryLight
                                          .withValues(alpha: 0.06)
                                      : null,
                              border: Border(
                                right: BorderSide(
                                  color: (col + 1) % 3 == 0 && col != 8
                                      ? (isDark
                                          ? Colors.white24
                                          : Colors.black26)
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.black12),
                                  width: (col + 1) % 3 == 0 && col != 8
                                      ? 2
                                      : 0.5,
                                ),
                                bottom: BorderSide(
                                  color: (row + 1) % 3 == 0 && row != 8
                                      ? (isDark
                                          ? Colors.white24
                                          : Colors.black26)
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.black12),
                                  width: (row + 1) % 3 == 0 && row != 8
                                      ? 2
                                      : 0.5,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                value != 0 ? '$value' : '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isFixed
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isError
                                      ? AppTheme.error
                                      : isFixed
                                          ? null
                                          : AppTheme.primaryLight,
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
            // Number pad
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  for (int i = 1; i <= 9; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GestureDetector(
                            onTap: () => _onNumberTap(i),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '$i',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _onErase,
                      icon: const Icon(Icons.backspace_rounded, size: 18),
                      label: Text(strings.erase),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(strings.newGame),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
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
