import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  String _difficulty = 'Fácil';
  List<_MemoryCard> _cards = [];
  int? _firstIndex;
  int? _secondIndex;
  bool _canTap = true;
  int _moves = 0;
  int _pairsFound = 0;
  int _totalPairs = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _timeText = '00:00';

  static const _icons = [
    Icons.favorite_rounded,
    Icons.star_rounded,
    Icons.diamond_rounded,
    Icons.bolt_rounded,
    Icons.local_fire_department_rounded,
    Icons.pets_rounded,
    Icons.music_note_rounded,
    Icons.emoji_nature_rounded,
    Icons.rocket_launch_rounded,
    Icons.palette_rounded,
    Icons.cake_rounded,
    Icons.beach_access_rounded,
    Icons.spa_rounded,
    Icons.auto_awesome_rounded,
    Icons.cloud_rounded,
    Icons.eco_rounded,
    Icons.emoji_food_beverage_rounded,
    Icons.filter_vintage_rounded,
  ];

  static const _cardColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B9D),
    Color(0xFF4ECDC4),
    Color(0xFFFFBE76),
    Color(0xFF45B7D1),
    Color(0xFFFF6B6B),
    Color(0xFFA29BFE),
    Color(0xFF55E6C1),
    Color(0xFFFF9FF3),
    Color(0xFFFECA57),
    Color(0xFF48DBFB),
    Color(0xFFFF6348),
    Color(0xFF7BED9F),
    Color(0xFFDDA0DD),
    Color(0xFF70A1FF),
    Color(0xFFFF7979),
    Color(0xFF2ED573),
    Color(0xFFFFB142),
  ];

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

  int get _gridSize {
    switch (_difficulty) {
      case 'Fácil':
        return 4; // 4x3 = 6 pairs
      case 'Difícil':
        return 6; // 6x4 = 12 pairs
      default:
        return 4; // 4x4 = 8 pairs
    }
  }

  int get _rows {
    switch (_difficulty) {
      case 'Fácil':
        return 3;
      case 'Difícil':
        return 4;
      default:
        return 4;
    }
  }

  void _startGame() {
    final cols = _gridSize;
    final rows = _rows;
    _totalPairs = (cols * rows) ~/ 2;

    final selectedIcons = List.generate(_totalPairs, (i) => i);
    final pairs = [...selectedIcons, ...selectedIcons];
    pairs.shuffle(Random());

    _cards = pairs.map((i) => _MemoryCard(
      icon: _icons[i % _icons.length],
      color: _cardColors[i % _cardColors.length],
      pairId: i,
    )).toList();

    _firstIndex = null;
    _secondIndex = null;
    _canTap = true;
    _moves = 0;
    _pairsFound = 0;
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

  void _onCardTap(int index) {
    if (!_canTap || _cards[index].isFlipped || _cards[index].isMatched) return;

    final provider = context.read<AppProvider>();
    provider.sound.playTap();

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _secondIndex = index;
      _moves++;
      _canTap = false;

      if (_cards[_firstIndex!].pairId == _cards[_secondIndex!].pairId) {
        // Match
        provider.sound.playSuccess();
        setState(() {
          _cards[_firstIndex!].isMatched = true;
          _cards[_secondIndex!].isMatched = true;
          _pairsFound++;
        });
        _firstIndex = null;
        _secondIndex = null;
        _canTap = true;

        if (_pairsFound == _totalPairs) {
          _stopwatch.stop();
          _timer?.cancel();
          _onGameComplete();
        }
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() {
            _cards[_firstIndex!].isFlipped = false;
            _cards[_secondIndex!].isFlipped = false;
            _firstIndex = null;
            _secondIndex = null;
            _canTap = true;
          });
        });
      }
    }
  }

  void _onGameComplete() {
    final provider = context.read<AppProvider>();
    provider.sound.playWin();

    final timeBonus = max(0, 300 - _stopwatch.elapsed.inSeconds);
    final moveBonus = max(0, (_totalPairs * 5) - _moves) * 5;
    final score = 50 + timeBonus + moveBonus;

    provider.recordGame(
      gameType: 'memory',
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
          gameTitle: 'Memoria',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memoria'),
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
            // Stats row
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
                    icon: Icons.touch_app_rounded,
                    label: '$_moves movimientos',
                    color: AppTheme.accent,
                  ),
                  _InfoChip(
                    icon: Icons.check_circle_rounded,
                    label: '$_pairsFound / $_totalPairs',
                    color: AppTheme.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Card grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _MemoryCardWidget(
                      card: card,
                      onTap: () => _onCardTap(index),
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

class _MemoryCard {
  final IconData icon;
  final Color color;
  final int pairId;
  bool isFlipped = false;
  bool isMatched = false;

  _MemoryCard({
    required this.icon,
    required this.color,
    required this.pairId,
  });
}

class _MemoryCardWidget extends StatelessWidget {
  final _MemoryCard card;
  final VoidCallback onTap;

  const _MemoryCardWidget({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showFront = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: showFront
              ? card.color.withValues(alpha: card.isMatched ? 0.3 : 1.0)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: showFront
                ? card.color.withValues(alpha: 0.5)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: showFront && !card.isMatched
              ? [
                  BoxShadow(
                    color: card.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showFront
                ? Icon(
                    card.icon,
                    key: const ValueKey('front'),
                    color: card.isMatched ? card.color.withValues(alpha: 0.5) : Colors.white,
                    size: 30,
                  )
                : Icon(
                    Icons.question_mark_rounded,
                    key: const ValueKey('back'),
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    size: 24,
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
