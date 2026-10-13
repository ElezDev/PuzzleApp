import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class BreakoutScreen extends StatefulWidget {
  const BreakoutScreen({super.key, this.initialDifficulty});

  final String? initialDifficulty;

  @override
  State<BreakoutScreen> createState() => _BreakoutScreenState();
}

class _Brick {
  double x = 0, y = 0, w = 0, h = 0;
  bool alive = true;
  Color color = AppTheme.primaryLight;
}

class _BreakoutScreenState extends State<BreakoutScreen>
    with SingleTickerProviderStateMixin {
  String _difficulty = 'Fácil';

  late final Ticker _ticker;
  Duration? _lastTick;

  double _width = 0;
  double _height = 0;
  double _paddleX = 0;
  final double _paddleW = 90;
  double _paddleY = 0;

  double _ballX = 0;
  double _ballY = 0;
  double _vx = 0;
  double _vy = 0;
  final double _radius = 8;
  double _speed = 320;

  List<_Brick>? _bricks;
  int _lives = 3;
  int _score = 0;
  bool _running = false;
  bool _recorded = false;

  int get _brickRows {
    switch (_difficulty) {
      case 'Difícil':
        return 5;
      case 'Medio':
        return 4;
      default:
        return 3;
    }
  }

  double get _baseSpeed {
    switch (_difficulty) {
      case 'Difícil':
        return 460;
      case 'Medio':
        return 390;
      default:
        return 320;
    }
  }

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty ?? _difficulty;
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startGame() {
    _lives = 3;
    _score = 0;
    _recorded = false;
    _speed = _baseSpeed;
    if (_paddleX == 0 && _width > 0) _paddleX = _width / 2;
    setState(() {
      _buildBricks();
      _launchBall();
      _running = true;
    });
  }

  void _buildBricks() {
    _bricks = [];
    if (_width <= 0) return;
    const cols = 8;
    const gap = 5.0;
    const brickH = 17.0;
    final brickW = (_width - gap * (cols + 1)) / cols;
    for (var r = 0; r < _brickRows; r++) {
      for (var c = 0; c < cols; c++) {
        final brick = _Brick()
          ..x = gap + c * (brickW + gap)
          ..y = 40 + r * (brickH + gap)
          ..w = brickW
          ..h = brickH
          ..color = _brickColor(r);
        _bricks!.add(brick);
      }
    }
  }

  Color _brickColor(int row) {
    final palette = [
      const Color(0xFFFF6B9D),
      const Color(0xFFFFBE76),
      const Color(0xFF4ECDC4),
      const Color(0xFF6C63FF),
      const Color(0xFFFF6B6B),
    ];
    return palette[row % palette.length];
  }

  void _launchBall() {
    _ballX = _width / 2;
    _ballY = _paddleY - _radius - 4;
    final angle = pi * (135 + Random().nextInt(40) ) / 180; // upward cone
    _vx = _speed * cos(angle);
    _vy = -_speed * sin(angle);
    if (Random().nextBool()) _vx = -_vx;
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == null) {
      _lastTick = elapsed;
      return;
    }
    final dt =
        (elapsed - _lastTick!).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = elapsed;
    if (!_running || _width <= 0) return;
    _step(dt);
    if (mounted) setState(() {});
  }

  void _step(double dt) {
    final prevX = _ballX;
    final prevY = _ballY;

    // Slow continuous acceleration as the match progresses.
    _speed = (_speed + dt * 6).clamp(_baseSpeed, 1100);

    _ballX += _vx * dt;
    _ballY += _vy * dt;

    // Side walls
    if (_ballX - _radius < 0) {
      _ballX = _radius;
      _vx = _vx.abs();
    } else if (_ballX + _radius > _width) {
      _ballX = _width - _radius;
      _vx = -_vx.abs();
    }
    // Top wall
    if (_ballY - _radius < 0) {
      _ballY = _radius;
      _vy = _vy.abs();
    }
    // Bottom: lost ball
    if (_ballY - _radius > _height) {
      _loseLife();
      return;
    }

    // Paddle
    final paddleTop = _paddleY;
    if (_vy > 0 &&
        prevY + _radius <= paddleTop &&
        _ballY + _radius >= paddleTop &&
        _ballX >= _paddleX - _paddleW / 2 - _radius &&
        _ballX <= _paddleX + _paddleW / 2 + _radius) {
      final rel = ((_ballX - _paddleX) / (_paddleW / 2)).clamp(-1.0, 1.0);
      final angle = rel * (pi / 3.2);
      final magnitude = _speed;
      _vy = -magnitude * cos(angle);
      _vx = magnitude * sin(angle);
      _ballY = paddleTop - _radius;
      _speed = min(_speed * 1.012, 1100);
    }

    // Bricks
    for (final brick in _bricks!) {
      if (!brick.alive) continue;
      if (_circleRectHit(_ballX, _ballY, _radius, brick)) {
        brick.alive = false;
        _score += 10;
        context.read<AppProvider>().sound.playSuccess();
        // Determine reflection side
        final fromTop = prevY + _radius <= brick.y;
        final fromLeft = prevX + _radius <= brick.x;
        if (fromTop || prevY - _radius >= brick.y + brick.h) {
          _vy = _vy.abs() * (fromTop ? -1 : 1);
        } else {
          _vx = _vx.abs() * (fromLeft ? -1 : 1);
        }
        _speed = min(_speed * 1.02, 1100);
        if (_bricks!.every((b) => !b.alive)) {
          _endGame(won: true);
        }
        return;
      }
    }
  }

  bool _circleRectHit(
      double cx, double cy, double r, _Brick brick) {
    final closestX = cx.clamp(brick.x, brick.x + brick.w);
    final closestY = cy.clamp(brick.y, brick.y + brick.h);
    final dx = cx - closestX;
    final dy = cy - closestY;
    return dx * dx + dy * dy <= r * r;
  }

  void _loseLife() {
    context.read<AppProvider>().sound.playError();
    _lives--;
    if (_lives <= 0) {
      _endGame(won: false);
      return;
    }
    setState(() => _launchBall());
  }

  void _endGame({required bool won}) {
    if (_recorded) return;
    _recorded = true;
    _running = false;
    if (won) context.read<AppProvider>().sound.playWin();

    final difficultyBonus = _difficulty == 'Difícil'
        ? 150
        : (_difficulty == 'Medio' ? 100 : 60);
    final score = won ? _score + difficultyBonus : max(0, _score ~/ 2);

    context.read<AppProvider>().recordGame(
          gameType: 'breakout',
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
          gameTitle: strings.gameName('breakout'),
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
        title: Text(strings.gameName('breakout')),
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
                    icon: Icons.favorite_rounded,
                    label: '$_lives',
                    color: AppTheme.error,
                  ),
                  _InfoChip(
                    icon: Icons.bolt_rounded,
                    label: strings.difficultyLabel(_difficulty),
                    color: AppTheme.primaryLight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _width = constraints.maxWidth;
                    _height = constraints.maxHeight;
                    _paddleY = _height - 24;
                    if (_bricks == null) {
                      _buildBricks();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _startGame();
                      });
                    }
                    return GestureDetector(
                      onHorizontalDragUpdate: (d) {
                        setState(() {
                          _paddleX = (_paddleX + d.delta.dx)
                              .clamp(_paddleW / 2, _width - _paddleW / 2);
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomPaint(
                          size: Size(_width, _height),
                          painter: _BreakoutPainter(
                            width: _width,
                            height: _height,
                            paddleX: _paddleX,
                            paddleW: _paddleW,
                            paddleY: _paddleY,
                            ballX: _ballX,
                            ballY: _ballY,
                            radius: _radius,
                            bricks: _bricks!,
                            running: _running,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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

class _BreakoutPainter extends CustomPainter {
  final double width;
  final double height;
  final double paddleX;
  final double paddleW;
  final double paddleY;
  final double ballX;
  final double ballY;
  final double radius;
  final List<_Brick> bricks;
  final bool running;

  _BreakoutPainter({
    required this.width,
    required this.height,
    required this.paddleX,
    required this.paddleW,
    required this.paddleY,
    required this.ballX,
    required this.ballY,
    required this.radius,
    required this.bricks,
    required this.running,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & Size(width, height),
        const Radius.circular(16),
      ),
      bgPaint,
    );

    // Paddle
    final paddlePaint = Paint()
      ..color = AppTheme.primaryLight
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(paddleX, paddleY),
          width: paddleW,
          height: 12,
        ),
        const Radius.circular(6),
      ),
      paddlePaint,
    );

    // Bricks
    for (final brick in bricks) {
      if (!brick.alive) continue;
      final paint = Paint()..color = brick.color;
      final glow = Paint()
        ..color = brick.color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final rect = Rect.fromLTWH(brick.x, brick.y, brick.w, brick.h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        glow,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        paint,
      );
    }

    // Ball
    if (running) {
      final ballPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(ballX, ballY), radius, ballPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BreakoutPainter oldDelegate) => true;
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