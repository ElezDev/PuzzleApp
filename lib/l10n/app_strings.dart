import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('es'),
    Locale('en'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _AppStringsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppStrings of(BuildContext context) {
    final strings = Localizations.of<AppStrings>(context, AppStrings);
    assert(strings != null, 'AppStrings not found in context');
    return strings!;
  }

  bool get isSpanish => locale.languageCode != 'en';
  String get dateLocale => isSpanish ? 'es' : 'en';

  String get appTitle => 'Puzless';
  String get defaultUsername => isSpanish ? 'Jugador' : 'Player';

  String get navGames => isSpanish ? 'Juegos' : 'Games';
  String get navProfile => isSpanish ? 'Perfil' : 'Profile';
  String get navSettings => isSpanish ? 'Ajustes' : 'Settings';

  String homeGreeting(String username) =>
      isSpanish ? '¡Hola, $username!' : 'Hi, $username!';
  String get homeChallengePrompt =>
      isSpanish ? '¿Listo para un desafío?' : 'Ready for a challenge?';
  String levelShort(int level) => isSpanish ? 'Nv. $level' : 'Lv. $level';
  String get progress => isSpanish ? 'Progreso' : 'Progress';
  String get played => isSpanish ? 'Jugados' : 'Played';
  String get won => isSpanish ? 'Ganados' : 'Won';
  String get streak => isSpanish ? 'Racha' : 'Streak';
  String get dailyChallenge => isSpanish ? 'Desafío Diario' : 'Daily Challenge';
  String get dailyChallengeCta => isSpanish
      ? '¡Completa el reto de hoy y gana XP extra!'
      : 'Complete today\'s challenge and earn extra XP!';
  String get games => isSpanish ? 'Juegos' : 'Games';

  String get profileLevelLabel => isSpanish ? 'Nivel' : 'Level';
  String get totalExperience =>
      isSpanish ? 'Experiencia Total' : 'Total Experience';
  String nextLevel(int level) =>
      isSpanish ? 'Siguiente nivel: Nv. $level' : 'Next level: Lv. $level';
  String get matchesPlayed => isSpanish ? 'Partidas' : 'Matches';
  String get victories => isSpanish ? 'Victorias' : 'Wins';
  String get currentStreak => isSpanish ? 'Racha actual' : 'Current streak';
  String get bestStreak => isSpanish ? 'Mejor racha' : 'Best streak';
  String get winRate => isSpanish ? 'Tasa de victoria' : 'Win rate';
  String get changeName => isSpanish ? 'Cambiar nombre' : 'Change name';
  String get yourName => isSpanish ? 'Tu nombre' : 'Your name';
  String get cancel => isSpanish ? 'Cancelar' : 'Cancel';
  String get save => isSpanish ? 'Guardar' : 'Save';

  String get settings => isSpanish ? 'Ajustes' : 'Settings';
  String get appearance => isSpanish ? 'Apariencia' : 'Appearance';
  String get darkMode => isSpanish ? 'Modo oscuro' : 'Dark mode';
  String get on => isSpanish ? 'Activado' : 'On';
  String get off => isSpanish ? 'Desactivado' : 'Off';
  String get soundAndVibration =>
      isSpanish ? 'Sonido y vibración' : 'Sound and haptics';
  String get sounds => isSpanish ? 'Sonidos' : 'Sounds';
  String get music => isSpanish ? 'Música' : 'Music';
  String get vibration => isSpanish ? 'Vibración' : 'Haptics';
  String get language => isSpanish ? 'Idioma' : 'Language';
  String get useSystemLanguage =>
      isSpanish ? 'Usar idioma del sistema' : 'Use system language';
  String get developerNotes =>
      isSpanish ? 'Notas del desarrollador' : 'Developer notes';
  String get about => isSpanish ? 'Acerca de' : 'About';
  String get version => isSpanish ? 'Versión' : 'Version';
  String get madeForCuriousMinds => isSpanish
      ? 'Hecho con amor para mentes curiosas'
      : 'Made with love for curious minds';

  String get creatorTitle => isSpanish ? 'CREADOR' : 'CREATOR';
  String get creatorFooter => isSpanish
      ? 'Esta experiencia fue imaginada, diseñada y construida por Edwin Ledezma by ElezDev.'
      : 'This experience was imagined, designed, and built by Edwin Ledezma by ElezDev.';
  String get developerSignature => 'EDWIN LEDEZMA BY ELEZDEV';
  String get developerCardTitle => isSpanish
      ? 'Esta app fue imaginada, diseñada y construida por Edwin Ledezma.'
      : 'This app was imagined, designed, and built by Edwin Ledezma.';
  String get developerCardBody => isSpanish
      ? 'Puzlessapp es un ritual de neón, lógica e intuición creado para mentes curiosas por ElezDev.'
      : 'Puzlessapp is a neon ritual of logic and intuition crafted for curious minds by ElezDev.';
  String get developerBadgeDesign =>
      isSpanish ? 'Diseño original' : 'Original design';
  String get developerBadgeBuild => 'Build by ElezDev';
  String get developerBadgeEnergy =>
      isSpanish ? 'Energía puzzle neón' : 'Neon puzzle energy';

  String get systemDefault => isSpanish ? 'Sistema' : 'System';
  String get spanish => isSpanish ? 'Español' : 'Spanish';
  String get english => 'English';
  String languageLabel(String code) {
    switch (code) {
      case 'es':
        return spanish;
      case 'en':
        return english;
      default:
        return systemDefault;
    }
  }

  String get dailyDifficultyLabel =>
      isSpanish ? 'Dificultad' : 'Difficulty';
  String get challengeCompleted =>
      isSpanish ? '¡Desafío completado!' : 'Challenge completed!';
  String challengeScore(int score) =>
      isSpanish ? 'Puntuación: $score' : 'Score: $score';
  String get playAgain => isSpanish ? 'Jugar de nuevo' : 'Play again';
  String get playNow => isSpanish ? '¡Jugar ahora!' : 'Play now!';

  String get congratulations =>
      isSpanish ? '¡Felicidades!' : 'Congratulations!';
  String get keepTrying => isSpanish ? '¡Sigue intentando!' : 'Keep trying!';
  String completedGame(String gameTitle) => isSpanish
      ? 'Has completado $gameTitle'
      : 'You completed $gameTitle';
  String get dontGiveUp =>
      isSpanish ? 'No te rindas, puedes hacerlo' : 'Don\'t give up, you can do it';
  String get points => isSpanish ? 'Puntos' : 'Points';
  String get time => isSpanish ? 'Tiempo' : 'Time';
  String get home => isSpanish ? 'Inicio' : 'Home';
  String get play => isSpanish ? 'Jugar' : 'Play';

  String get versusAi => isSpanish ? 'vs IA' : 'vs AI';
  String get versusPlayer => isSpanish ? 'vs Jugador' : 'vs Player';
  String turnOf(String player) =>
      isSpanish ? 'Turno de $player' : '$player\'s turn';
  String winnerText(String winner) =>
      isSpanish ? '¡$winner gana!' : '$winner wins!';
  String get draw => isSpanish ? '¡Empate!' : 'Draw!';
  String get newMatch => isSpanish ? 'Nueva partida' : 'New match';
  String ticTacToeGameTitle({bool draw = false}) {
    final game = gameName('tic_tac_toe');
    return draw ? '$game - ${isSpanish ? 'Empate' : 'Draw'}' : game;
  }

  String movesCount(int moves) =>
      isSpanish ? '$moves movimientos' : '$moves moves';
  String pairsProgress(int found, int total) => '$found / $total';
  String get restart => isSpanish ? 'Reiniciar' : 'Restart';

  String roundLabel(int round) =>
      isSpanish ? 'Ronda $round' : 'Round $round';
  String pointsShort(int score) =>
      isSpanish ? '$score pts' : '$score pts';
  String get watchSequence => isSpanish
      ? 'Observa la secuencia...'
      : 'Watch the sequence...';
  String get repeatSequence => isSpanish
      ? 'Tu turno - repite la secuencia'
      : 'Your turn - repeat the sequence';
  String patternGameTitle(int round) =>
      '${gameName('pattern')} - ${roundLabel(round)}';

  String errorsLabel(int errors, int maxErrors) => isSpanish
      ? 'Errores: $errors/$maxErrors'
      : 'Errors: $errors/$maxErrors';
  String get erase => isSpanish ? 'Borrar' : 'Erase';
  String get newGame => isSpanish ? 'Nuevo' : 'New';

  String colorMatchInstruction() => isSpanish
      ? '¿De qué COLOR está escrita la palabra?'
      : 'What COLOR is the word written in?';
  String colorMatchGameTitle(int round) =>
      '${gameName('color_match')} - ${roundLabel(round)}';

  String difficultyLabel(String value) {
    switch (value) {
      case 'Fácil':
        return isSpanish ? 'Fácil' : 'Easy';
      case 'Medio':
        return isSpanish ? 'Medio' : 'Medium';
      case 'Difícil':
        return isSpanish ? 'Difícil' : 'Hard';
      default:
        return value;
    }
  }

  String colorName(String value) {
    switch (value) {
      case 'Rojo':
        return isSpanish ? 'Rojo' : 'Red';
      case 'Azul':
        return isSpanish ? 'Azul' : 'Blue';
      case 'Verde':
        return isSpanish ? 'Verde' : 'Green';
      case 'Amarillo':
        return isSpanish ? 'Amarillo' : 'Yellow';
      case 'Morado':
        return isSpanish ? 'Morado' : 'Purple';
      case 'Naranja':
        return isSpanish ? 'Naranja' : 'Orange';
      case 'Rosa':
        return isSpanish ? 'Rosa' : 'Pink';
      case 'Cian':
        return isSpanish ? 'Cian' : 'Cyan';
      default:
        return value;
    }
  }

  String gameName(String id) {
    switch (id) {
      case 'tic_tac_toe':
        return isSpanish ? 'Triqui' : 'Tic-Tac-Toe';
      case 'memory':
        return isSpanish ? 'Memoria' : 'Memory';
      case 'slide_puzzle':
        return isSpanish ? 'Deslizar' : 'Slide Puzzle';
      case 'pattern':
        return isSpanish ? 'Patrones' : 'Patterns';
      case 'sudoku':
        return 'Sudoku';
      case 'color_match':
        return 'Color Match';
      default:
        return id;
    }
  }

  String gameDescription(String id) {
    switch (id) {
      case 'tic_tac_toe':
        return isSpanish ? 'El clásico tres en raya' : 'The classic three-in-a-row';
      case 'memory':
        return isSpanish ? 'Encuentra los pares ocultos' : 'Find the hidden pairs';
      case 'slide_puzzle':
        return isSpanish ? 'Ordena las piezas deslizando' : 'Arrange the tiles by sliding';
      case 'pattern':
        return isSpanish ? 'Repite la secuencia de colores' : 'Repeat the color sequence';
      case 'sudoku':
        return isSpanish ? 'Completa la cuadrícula numérica' : 'Complete the number grid';
      case 'color_match':
        return isSpanish ? 'Acierta el color correcto' : 'Pick the correct color';
      default:
        return id;
    }
  }

  String gameCategory(String id) {
    switch (id) {
      case 'tic_tac_toe':
        return isSpanish ? 'Clásicos' : 'Classics';
      case 'memory':
      case 'pattern':
        return isSpanish ? 'Memoria' : 'Memory';
      case 'slide_puzzle':
      case 'sudoku':
        return isSpanish ? 'Lógica' : 'Logic';
      case 'color_match':
        return isSpanish ? 'Reflejos' : 'Reflexes';
      default:
        return '';
    }
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppStrings.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
