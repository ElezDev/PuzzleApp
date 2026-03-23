import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with TickerProviderStateMixin {
  List<String> _board = List.filled(9, '');
  bool _isXTurn = true;
  String _difficulty = 'Medio';
  bool _vsPlayer = false;
  bool _gameOver = false;
  String _winner = '';
  List<int> _winLine = [];
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _isXTurn = true;
      _gameOver = false;
      _winner = '';
      _winLine = [];
    });
  }

  void _makeMove(int index) {
    if (_board[index].isNotEmpty || _gameOver) return;

    final provider = context.read<AppProvider>();
    provider.sound.playTap();

    setState(() {
      _board[index] = _isXTurn ? 'X' : 'O';
      _isXTurn = !_isXTurn;
    });

    _checkGameEnd();

    if (!_gameOver && !_vsPlayer && !_isXTurn) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted || _gameOver) return;
        _aiMove();
      });
    }
  }

  void _aiMove() {
    int move;
    switch (_difficulty) {
      case 'Fácil':
        move = _getRandomMove();
      case 'Difícil':
        move = _getBestMove();
      default:
        move = Random().nextBool() ? _getBestMove() : _getRandomMove();
    }

    if (move != -1) {
      setState(() {
        _board[move] = 'O';
        _isXTurn = true;
      });
      _checkGameEnd();
    }
  }

  int _getRandomMove() {
    final empty = <int>[];
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) empty.add(i);
    }
    if (empty.isEmpty) return -1;
    return empty[Random().nextInt(empty.length)];
  }

  int _getBestMove() {
    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'O';
        int score = _minimax(false, 0);
        _board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int _minimax(bool isMaximizing, int depth) {
    final winner = _checkWinner();
    if (winner == 'O') return 10 - depth;
    if (winner == 'X') return depth - 10;
    if (!_board.contains('')) return 0;

    if (isMaximizing) {
      int best = -1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i].isEmpty) {
          _board[i] = 'O';
          best = max(best, _minimax(false, depth + 1));
          _board[i] = '';
        }
      }
      return best;
    } else {
      int best = 1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i].isEmpty) {
          _board[i] = 'X';
          best = min(best, _minimax(true, depth + 1));
          _board[i] = '';
        }
      }
      return best;
    }
  }

  String _checkWinner() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (final line in lines) {
      if (_board[line[0]].isNotEmpty &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[1]] == _board[line[2]]) {
        return _board[line[0]];
      }
    }
    return '';
  }

  List<int> _getWinLine() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (final line in lines) {
      if (_board[line[0]].isNotEmpty &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[1]] == _board[line[2]]) {
        return line;
      }
    }
    return [];
  }

  void _checkGameEnd() {
    final winner = _checkWinner();
    if (winner.isNotEmpty) {
      setState(() {
        _gameOver = true;
        _winner = winner;
        _winLine = _getWinLine();
      });
      _showResult(winner == 'X');
    } else if (!_board.contains('')) {
      setState(() {
        _gameOver = true;
        _winner = '';
      });
      _showResult(false, isDraw: true);
    }
  }

  void _showResult(bool won, {bool isDraw = false}) {
    final provider = context.read<AppProvider>();
    if (won) provider.sound.playWin();

    final score = won ? 100 : (isDraw ? 30 : 0);
    provider.recordGame(
      gameType: 'tic_tac_toe',
      difficulty: _difficulty,
      score: score,
      won: won,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameResultDialog(
          won: won,
          score: score,
          gameTitle: isDraw ? 'Triqui - Empate' : 'Triqui',
          onPlayAgain: () {
            Navigator.pop(context);
            _resetGame();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triqui'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Mode toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: 'vs IA',
                      icon: Icons.smart_toy_rounded,
                      selected: !_vsPlayer,
                      onTap: () {
                        setState(() => _vsPlayer = false);
                        _resetGame();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ModeButton(
                      label: 'vs Jugador',
                      icon: Icons.people_rounded,
                      selected: _vsPlayer,
                      onTap: () {
                        setState(() => _vsPlayer = true);
                        _resetGame();
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (!_vsPlayer) ...[
              const SizedBox(height: 12),
              DifficultySelector(
                selected: _difficulty,
                onChanged: (d) {
                  setState(() => _difficulty = d);
                  _resetGame();
                },
              ),
            ],
            const SizedBox(height: 16),
            // Turn indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _gameOver
                    ? (_winner.isNotEmpty ? '¡$_winner gana!' : '¡Empate!')
                    : 'Turno de ${_isXTurn ? "X" : "O"}',
                key: ValueKey('$_isXTurn$_gameOver'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: _isXTurn ? AppTheme.primaryLight : AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Board
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryLight.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        final isWinCell = _winLine.contains(index);
                        return _BoardCell(
                          value: _board[index],
                          isWinCell: isWinCell,
                          onTap: () => _makeMove(index),
                          disabled: _gameOver ||
                              (!_vsPlayer && !_isXTurn) ||
                              _board[index].isNotEmpty,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Reset button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Nueva partida'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryLight.withValues(alpha: 0.12)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppTheme.primaryLight
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: selected ? AppTheme.primaryLight : null),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.primaryLight : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardCell extends StatefulWidget {
  final String value;
  final bool isWinCell;
  final VoidCallback onTap;
  final bool disabled;

  const _BoardCell({
    required this.value,
    required this.isWinCell,
    required this.onTap,
    required this.disabled,
  });

  @override
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(covariant _BoardCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.isNotEmpty && oldWidget.value.isEmpty) {
      _controller.forward(from: 0);
    }
    if (widget.value.isEmpty && oldWidget.value.isNotEmpty) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isX = widget.value == 'X';
    final color = isX ? AppTheme.primaryLight : AppTheme.accent;

    return GestureDetector(
      onTap: widget.disabled ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: widget.isWinCell
              ? color.withValues(alpha: 0.15)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: widget.value.isNotEmpty
                ? Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
