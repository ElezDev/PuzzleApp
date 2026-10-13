import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class TetrisScreen extends StatefulWidget {
  const TetrisScreen({super.key, this.initialDifficulty});

  final String? initialDifficulty;

  @override
  State<TetrisScreen> createState() => _TetrisScreenState();
}

class _Piece {
  List<List<int>> shape;
  Color color;
  int x;
  int y;

  _Piece(this.shape, this.color, this.x, this.y);
}

class _TetrisScreenState extends State<TetrisScreen> {
  static const int _cols = 10;
  static const int _rows = 20;

  String _difficulty = 'Fácil';
  late List<int> _board;
  _Piece? _current;
  int _score = 0;
  int _lines = 0;
  int _level = 1;
  Timer? _gravity;
  bool _gameOver = false;
  bool _recorded = false;

  static const _colors = {
    'I': Color(0xFF00E5FF),
    'O': Color(0xFFFFD600),
    'T': Color(0xFFB388FF),
    'S': Color(0xFF69F0AE),
    'Z': Color(0xFFFF5252),
    'J': Color(0xFF448AFF),
    'L': Color(0xFFFFAB40),
  };

  static const _pieceShapes = <String, List<List<int>>>{
    'I': [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
    ],
    'O': [
      [1, 1],
      [1, 1],
    ],
    'T': [
      [0, 1, 0],
      [1, 1, 1],
    ],
    'S': [
      [0, 1, 1],
      [1, 1, 0],
    ],
    'Z': [
      [1, 1, 0],
      [0, 1, 1],
    ],
    'J': [
      [1, 0, 0],
      [1, 1, 1],
    ],
    'L': [
      [0, 0, 1],
      [1, 1, 1],
    ],
  };

  int get _targetLines {
    switch (_difficulty) {
      case 'Difícil':
        return 16;
      case 'Medio':
        return 12;
      default:
        return 8;
    }
  }

  Duration get _gravityInterval {
    final ms = switch (_difficulty) {
      'Medio' => 550,
      'Difícil' => 380,
      _ => 750,
    };
    return Duration(milliseconds: (ms / (1 + (_level - 1) * 0.15)).round());
  }

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty ?? _difficulty;
    _startGame();
  }

  @override
  void dispose() {
    _gravity?.cancel();
    super.dispose();
  }

  void _startGame() {
    _board = List<int>.filled(_cols * _rows, 0, growable: false);
    _score = 0;
    _lines = 0;
    _level = 1;
    _gameOver = false;
    _recorded = false;
    _spawnPiece();
    _restartGravity();
    setState(() {});
  }

  void _restartGravity() {
    _gravity?.cancel();
    _gravity = Timer.periodic(_gravityInterval, (_) {
      if (!mounted || _gameOver) return;
      _moveDown();
    });
  }

  int _cell(int c, int r) {
    if (r < 0) return 0;
    if (r >= _rows || c < 0 || c >= _cols) return 0;
    return _board[r * _cols + c];
  }

  void _setCell(int c, int r, int v) {
    if (r < 0 || r >= _rows) return;
    if (c < 0 || c >= _cols) return;
    _board[r * _cols + c] = v;
  }

  void _spawnPiece() {
    final keys = _pieceShapes.keys.toList();
    final id = keys[DateTime.now().microsecondsSinceEpoch % keys.length];
    final shape = _pieceShapes[id]!.map((row) => List<int>.from(row)).toList();
    final spawnX = (_cols ~/ 2) - (shape[0].length ~/ 2);
    final piece = _Piece(shape, _colors[id]!, spawnX, -shape.length + 1);
    _current = piece;
    if (_isColliding(piece)) {
      _endGame(won: false);
    }
  }

  bool _isColliding(_Piece piece) {
    final shape = piece.shape;
    for (var r = 0; r < shape.length; r++) {
      for (var c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 0) continue;
        final x = piece.x + c;
        final y = piece.y + r;
        if (x < 0 || x >= _cols || y >= _rows) return true;
        if (y >= 0 && _cell(x, y) != 0) return true;
      }
    }
    return false;
  }

  void _mergePiece() {
    final shape = _current!.shape;
    for (var r = 0; r < shape.length; r++) {
      for (var c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 0) continue;
        _setCell(_current!.x + c, _current!.y + r, 1);
      }
    }
  }

  void _clearLines() {
    var cleared = 0;
    for (var r = 0; r < _rows; r++) {
      var full = true;
      for (var c = 0; c < _cols; c++) {
        if (_cell(c, r) == 0) {
          full = false;
          break;
        }
      }
      if (full) {
        for (var rr = r; rr > 0; rr--) {
          for (var c = 0; c < _cols; c++) {
            _setCell(c, rr, _cell(c, rr - 1));
          }
        }
        for (var c = 0; c < _cols; c++) {
          _setCell(c, 0, 0);
        }
        cleared++;
      }
    }
    if (cleared > 0) {
      final points = [0, 100, 300, 500, 800];
      _score += points[cleared.clamp(0, 4)];
      _lines += cleared;
      _level = 1 + (_lines ~/ 4);
      context.read<AppProvider>().sound.playSuccess();
    }
  }

  void _lockPiece() {
    _mergePiece();
    _clearLines();

    if (_lines >= _targetLines) {
      _endGame(won: true);
      return;
    }
    _spawnPiece();
    if (!_gameOver) _restartGravity();
    setState(() {});
  }

  void _moveDown() {
    if (_gameOver) return;
    final piece = _current!..y = _current!.y + 1;
    if (_isColliding(piece)) {
      _current!.y -= 1;
      _lockPiece();
    } else {
      _current = piece;
      setState(() {});
    }
  }

  void _moveHorizontal(int dx) {
    if (_gameOver) return;
    final piece = _current!..x = _current!.x + dx;
    if (!_isColliding(piece)) {
      _current = piece;
      setState(() {});
    }
  }

  void _rotate() {
    if (_gameOver) return;
    final shape = _current!.shape;
    final rotated = List.generate(
      shape[0].length,
      (c) => List.generate(shape.length, (r) => shape[shape.length - 1 - r][c]),
    );
    final piece = _Piece(rotated, _current!.color, _current!.x, _current!.y);
    if (!_isColliding(piece)) {
      _current = piece;
      return;
    }
    // Wall kick: try shifting left/right.
    for (final dx in [-1, 1, -2, 2]) {
      final kicked = _Piece(rotated, _current!.color, _current!.x + dx, _current!.y);
      if (!_isColliding(kicked)) {
        _current = kicked;
        return;
      }
    }
    setState(() {});
  }

  void _hardDrop() {
    if (_gameOver) return;
    var drop = 0;
    var test = _current!.y;
    while (!_isColliding(_Piece(_current!.shape, _current!.color, _current!.x, test + 1))) {
      test++;
      drop++;
    }
    _current!.y = test;
    _score += drop * 2;
    _lockPiece();
  }

  void _endGame({required bool won}) {
    if (_recorded) return;
    _recorded = true;
    _gameOver = true;
    _gravity?.cancel();
    if (won) {
      context.read<AppProvider>().sound.playWin();
    } else {
      context.read<AppProvider>().sound.playError();
    }

    final difficultyBonus = _difficulty == 'Difícil'
        ? 400
        : (_difficulty == 'Medio' ? 250 : 150);
    final score = won ? _score + difficultyBonus : _score;

    context.read<AppProvider>().recordGame(
          gameType: 'tetris',
          difficulty: _difficulty,
          score: score,
          won: won,
        );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final strings = AppStrings.of(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameResultDialog(
          won: won,
          score: score,
          gameTitle: strings.gameName('tetris'),
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
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.gameName('tetris')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _onKeyEvent,
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
              const SizedBox(height: 10),
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
                      icon: Icons.layers_rounded,
                      label: '$_lines / $_targetLines',
                      color: AppTheme.success,
                    ),
                    _InfoChip(
                      icon: Icons.bolt_rounded,
                      label: strings.levelShort(_level),
                      color: AppTheme.primaryLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _BoardView(
                        board: _board,
                        cols: _cols,
                        rows: _rows,
                        current: _current,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _Controls(
                onLeft: () => _moveHorizontal(-1),
                onRight: () => _moveHorizontal(1),
                onRotate: _rotate,
                onDown: _moveDown,
                onDrop: _hardDrop,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  final FocusNode _focusNode = FocusNode();

  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveHorizontal(-1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _moveHorizontal(1);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _moveDown();
    } else if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.space) {
      _rotate();
    }
  }
}

class _BoardView extends StatelessWidget {
  final List<int> board;
  final int cols;
  final int rows;
  final _Piece? current;

  const _BoardView({
    required this.board,
    required this.cols,
    required this.rows,
    required this.current,
  });

  int _cell(int c, int r) {
    if (r < 0 || c < 0 || c >= cols || r >= rows) return 0;
    return board[r * cols + c];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: cols / rows,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: List.generate(rows, (r) {
            return Expanded(
              child: Row(
                children: List.generate(cols, (c) {
                  var value = _cell(c, r);
                  var color = Colors.white;
                  if (current != null) {
                    final shape = current!.shape;
                    final lr = r - current!.y;
                    final lc = c - current!.x;
                    if (lr >= 0 &&
                        lr < shape.length &&
                        lc >= 0 &&
                        lc < shape[lr].length &&
                        shape[lr][lc] != 0) {
                      value = 2;
                      color = current!.color;
                    }
                  }
                  final isEmpty = value == 0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isEmpty
                              ? Colors.transparent
                              : color.withValues(alpha: value == 2 ? 1.0 : 0.85),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onRotate;
  final VoidCallback onDown;
  final VoidCallback onDrop;

  const _Controls({
    required this.onLeft,
    required this.onRight,
    required this.onRotate,
    required this.onDown,
    required this.onDrop,
  });

  Widget _btn(IconData icon, VoidCallback onTap, {Color? color}) {
    final tint = color ?? AppTheme.primaryLight;
    return SizedBox.expand(
      child: Material(
        color: tint.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tint.withValues(alpha: 0.45)),
            ),
            child: Center(
              child: Icon(icon, color: tint, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: _btn(Icons.arrow_left_rounded, onLeft),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: _btn(Icons.refresh_rounded, onRotate,
                      color: AppTheme.success),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: _btn(Icons.arrow_right_rounded, onRight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: _btn(Icons.arrow_downward_rounded, onDown,
                      color: AppTheme.warning),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 54,
                  child: _btn(Icons.arrow_circle_down_rounded, onDrop,
                      color: AppTheme.primaryLight),
                ),
              ),
            ],
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