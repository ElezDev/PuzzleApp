import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../widgets/difficulty_selector.dart';
import '../../widgets/game_result_dialog.dart';

class HangmanScreen extends StatefulWidget {
  const HangmanScreen({super.key, this.initialDifficulty});

  final String? initialDifficulty;

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> {
  String _difficulty = 'Fácil';
  late String _word;
  late String _category;
  late String _hintEs;
  late String _hintEn;
  bool _hintRevealed = false;
  final Set<String> _guessed = {};
  int _wrong = 0;
  int _score = 0;
  bool _gameOver = false;

  static const _keyboardRows = [
    'QWERTYUIOP',
    'ASDFGHJKLÑ',
    'ZXCVBNM',
  ];

  static const _wordsEasy = [
    _HangmanWord('CASA', 'lugar', 'Lugar donde vives', 'Place where you live'),
    _HangmanWord('GATO', 'animal', 'Animal doméstico que dice miau',
        'Pet that says meow'),
    _HangmanWord('LUNA', 'naturaleza', 'Brilla en el cielo de noche',
        'Shines in the night sky'),
    _HangmanWord('MESA', 'objeto', 'Mueble donde comes o trabajas',
        'Furniture where you eat or work'),
    _HangmanWord('ROJO', 'color', 'Color de la sangre', 'Color of blood'),
    _HangmanWord('AGUA', 'naturaleza', 'Líquido esencial para vivir',
        'Essential liquid for life'),
    _HangmanWord('LIBRO', 'objeto', 'Tiene páginas para leer',
        'Has pages to read'),
    _HangmanWord('PERRO', 'animal', 'El mejor amigo del hombre',
        'Man\'s best friend'),
    _HangmanWord('CIELO', 'naturaleza', 'Está sobre nosotros',
        'It is above us'),
    _HangmanWord('NIEVE', 'naturaleza', 'Blanca, cae en invierno',
        'White, falls in winter'),
    _HangmanWord('PLAYA', 'lugar', 'Arena junto al mar', 'Sand by the sea'),
    _HangmanWord('TIGRE', 'animal', 'Felino naranja con rayas',
        'Orange feline with stripes'),
    _HangmanWord('FUEGO', 'naturaleza', 'Está caliente y quema',
        'It is hot and burns'),
    _HangmanWord('NUBE', 'naturaleza', 'Flota blanca en el cielo',
        'Floats white in the sky'),
  ];

  static const _wordsMedium = [
    _HangmanWord('ESCUELA', 'lugar', 'Lugar donde aprendes',
        'Place where you learn'),
    _HangmanWord('VENTANA', 'objeto', 'Abertura para ver afuera',
        'Opening to see outside'),
    _HangmanWord('JARDIN', 'lugar', 'Lugar con plantas y flores',
        'Place with plants and flowers'),
    _HangmanWord('MUSICA', 'arte', 'Arte hecha de sonidos',
        'Art made of sounds'),
    _HangmanWord('CIUDAD', 'lugar', 'Conjunto grande de calles y edificios',
        'Large set of streets and buildings'),
    _HangmanWord('CAMINO', 'lugar', 'Vía por donde se anda',
        'Path used to walk'),
    _HangmanWord('PASTEL', 'comida', 'Dulce de cumpleaños',
        'Birthday sweet'),
    _HangmanWord('PLANETA', 'naturaleza', 'Gira alrededor del Sol',
        'Orbits around the Sun'),
    _HangmanWord('ANIMAL', 'naturaleza', 'Ser vivo que se mueve',
        'Living being that moves'),
    _HangmanWord('BOTELLA', 'objeto', 'Recipiente para líquidos',
        'Container for liquids'),
    _HangmanWord('PELOTA', 'objeto', 'Sirve para jugar y rebota',
        'Used to play and bounces'),
    _HangmanWord('VENTILADOR', 'objeto', 'Aparato que da aire',
        'Device that blows air'),
  ];

  static const _wordsHard = [
    _HangmanWord('ELEFANTE', 'animal', 'Animal enorme con trompa',
        'Huge animal with a trunk'),
    _HangmanWord('MARIPOSA', 'animal', 'Insecto de alas coloridas',
        'Insect with colorful wings'),
    _HangmanWord('BIBLIOTECA', 'lugar', 'Lugar lleno de libros',
        'Place full of books'),
    _HangmanWord('CHOCOLATE', 'comida', 'Dulce hecho de cacao',
        'Sweet made from cocoa'),
    _HangmanWord('TELESCOPIO', 'objeto', 'Instrumento para ver las estrellas',
        'Instrument to see the stars'),
    _HangmanWord('MONTAÑA', 'naturaleza', 'Gran elevación de terreno',
        'Large elevation of land'),
    _HangmanWord('ARAÑA', 'animal', 'Animal que teje telarañas',
        'Animal that weaves webs'),
    _HangmanWord('ESPAÑA', 'lugar', 'País donde se habla español',
        'Country where Spanish is spoken'),
    _HangmanWord('CALABAZA', 'comida', 'Verdura naranja de Halloween',
        'Orange Halloween vegetable'),
    _HangmanWord('DINOSAURIO', 'animal', 'Reptil gigante ya extinto',
        'Giant reptile now extinct'),
  ];

  int get _maxWrong {
    switch (_difficulty) {
      case 'Fácil':
        return 8;
      case 'Difícil':
        return 5;
      default:
        return 6;
    }
  }

  List<_HangmanWord> get _wordBank {
    switch (_difficulty) {
      case 'Fácil':
        return _wordsEasy;
      case 'Difícil':
        return _wordsHard;
      default:
        return _wordsMedium;
    }
  }

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty ?? _difficulty;
    _startGame();
  }

  void _startGame() {
    final rand = Random();
    final entry = _wordBank[rand.nextInt(_wordBank.length)];
    _word = entry.word;
    _category = entry.category;
    _hintEs = entry.hintEs;
    _hintEn = entry.hintEn;
    _hintRevealed = false;
    _guessed.clear();
    _wrong = 0;
    _score = 0;
    _gameOver = false;
    setState(() {});
  }

  bool get _won => _word.split('').every(_guessed.contains);

  void _onLetterTap(String letter) {
    if (_gameOver || _guessed.contains(letter)) return;

    final provider = context.read<AppProvider>();
    final correct = _word.contains(letter);

    setState(() {
      _guessed.add(letter);
      if (!correct) _wrong++;
    });

    if (correct) {
      provider.sound.playTap();
    } else {
      provider.sound.playError();
    }

    if (_won) {
      _finish(true);
    } else if (_wrong >= _maxWrong) {
      _finish(false);
    }
  }

  void _finish(bool won) {
    if (_gameOver) return;
    _gameOver = true;

    final provider = context.read<AppProvider>();
    final difficultyBonus = _difficulty == 'Fácil'
        ? 0
        : _difficulty == 'Medio'
            ? 20
            : 40;
    final remaining = _maxWrong - _wrong;
    _score = won
        ? _word.length * 10 + remaining * 15 + difficultyBonus
        : _word.split('').where(_guessed.contains).length * 5;

    if (won) {
      provider.sound.playWin();
    }

    provider.recordGame(
      gameType: 'hangman',
      difficulty: _difficulty,
      score: _score,
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
          score: _score,
          gameTitle: strings.gameName('hangman'),
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
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.gameName('hangman')),
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
                    icon: Icons.favorite_rounded,
                    label: strings.attemptsLeft(
                      (_maxWrong - _wrong).clamp(0, _maxWrong),
                    ),
                    color: AppTheme.error,
                  ),
                  _InfoChip(
                    icon: Icons.text_fields_rounded,
                    label: '${_word.length}',
                    color: AppTheme.primaryLight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InfoChip(
                    icon: Icons.category_rounded,
                    label: strings.hangmanCategory(_category),
                    color: AppTheme.primaryLight,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.lightbulb_outline_rounded,
                    label: _hintRevealed
                        ? strings.hintLabel
                        : strings.showHint,
                    color: _hintRevealed
                        ? AppTheme.success
                        : AppTheme.warning,
                    onTap: _hintRevealed || _gameOver
                        ? null
                        : () => setState(() => _hintRevealed = true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_hintRevealed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lightbulb_rounded,
                                  size: 18,
                                  color: AppTheme.warning,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  strings.isSpanish ? _hintEs : _hintEn,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 12,
                          children: _word
                              .split('')
                              .map((letter) => _LetterBox(
                                    letter: letter,
                                    revealed: _guessed.contains(letter) ||
                                        _gameOver && _wrong >= _maxWrong,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_gameOver && !_won)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  strings.wordWas(_word),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
              ),
            if (!_gameOver)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  strings.pickLetter,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: _keyboardRows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: row.split('').map((letter) {
                          return _KeyButton(
                            letter: letter,
                            state: !_guessed.contains(letter)
                                ? _KeyState.idle
                                : _word.contains(letter)
                                    ? _KeyState.correct
                                    : _KeyState.wrong,
                            onTap: () => _onLetterTap(letter),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _KeyState { idle, correct, wrong }

class _KeyButton extends StatelessWidget {
  final String letter;
  final _KeyState state;
  final VoidCallback onTap;

  const _KeyButton({
    required this.letter,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground) = switch (state) {
      _KeyState.correct => (AppTheme.success, Colors.white),
      _KeyState.wrong => (AppTheme.error.withValues(alpha: 0.85), Colors.white),
      _KeyState.idle => (
          theme.cardColor,
          theme.textTheme.bodyLarge?.color ?? Colors.black,
        ),
    };

    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        width: 32,
        height: 42,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: state == _KeyState.idle ? onTap : null,
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterBox extends StatelessWidget {
  final String letter;
  final bool revealed;

  const _LetterBox({required this.letter, required this.revealed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = revealed
        ? (AppTheme.primaryLight)
        : theme.textTheme.bodyLarge?.color ?? Colors.black;

    return SizedBox(
      width: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            revealed ? letter : '',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
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
  final VoidCallback? onTap;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
      ),
    );
  }
}

class _HangmanWord {
  const _HangmanWord(this.word, this.category, this.hintEs, this.hintEn);

  final String word;
  final String category;
  final String hintEs;
  final String hintEn;
}
