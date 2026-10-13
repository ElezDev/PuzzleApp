import 'package:flutter/material.dart';

class GameInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  final String category;
  final bool supportsMultiplayer;
  final int requiredLevel;

  const GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradientEnd,
    required this.category,
    this.supportsMultiplayer = false,
    this.requiredLevel = 1,
  });

  /// Games unlock one at a time: [requiredLevel] equals the player level
  /// needed to play it. Triqui is available from the start (level 1) and the
  /// "top" games sit at the highest levels to reward progression.
  static const List<GameInfo> allGames = [
    GameInfo(
      id: 'tic_tac_toe',
      name: 'Triqui',
      description: 'El clásico tres en raya',
      icon: Icons.grid_3x3_rounded,
      color: Color(0xFF6C63FF),
      gradientEnd: Color(0xFF8B83FF),
      category: 'Clásicos',
      supportsMultiplayer: true,
      requiredLevel: 1,
    ),
    GameInfo(
      id: 'memory',
      name: 'Memoria',
      description: 'Encuentra los pares ocultos',
      icon: Icons.psychology_rounded,
      color: Color(0xFFFF6B9D),
      gradientEnd: Color(0xFFFF8FB1),
      category: 'Memoria',
      requiredLevel: 2,
    ),
    GameInfo(
      id: 'slide_puzzle',
      name: 'Deslizar',
      description: 'Ordena las piezas deslizando',
      icon: Icons.view_comfy_rounded,
      color: Color(0xFF4ECDC4),
      gradientEnd: Color(0xFF6EE7DE),
      category: 'Lógica',
      requiredLevel: 3,
    ),
    GameInfo(
      id: 'pattern',
      name: 'Patrones',
      description: 'Repite la secuencia de colores',
      icon: Icons.palette_rounded,
      color: Color(0xFFFFBE76),
      gradientEnd: Color(0xFFFFD093),
      category: 'Memoria',
      requiredLevel: 4,
    ),
    GameInfo(
      id: 'sudoku',
      name: 'Sudoku',
      description: 'Completa la cuadrícula numérica',
      icon: Icons.apps_rounded,
      color: Color(0xFF45B7D1),
      gradientEnd: Color(0xFF6CCFE0),
      category: 'Lógica',
      requiredLevel: 5,
    ),
    GameInfo(
      id: 'color_match',
      name: 'Color Match',
      description: 'Acierta el color correcto',
      icon: Icons.colorize_rounded,
      color: Color(0xFFFF6B6B),
      gradientEnd: Color(0xFFFF8E8E),
      category: 'Reflejos',
      requiredLevel: 6,
    ),
    GameInfo(
      id: '2048',
      name: '2048',
      description: 'Une los números y llega a 2048',
      icon: Icons.grid_on_rounded,
      color: Color(0xFFF97F51),
      gradientEnd: Color(0xFFFFA26B),
      category: 'Números',
      requiredLevel: 7,
    ),
    GameInfo(
      id: 'breakout',
      name: 'Breakout',
      description: 'Rompe los bloques, la pelota acelera',
      icon: Icons.sports_baseball_rounded,
      color: Color(0xFFFF5252),
      gradientEnd: Color(0xFFFF7B7B),
      category: 'Arcade',
      requiredLevel: 8,
    ),
    GameInfo(
      id: 'minesweeper',
      name: 'Buscaminas',
      description: 'Despeja el campo sin pisar minas',
      icon: Icons.flag_rounded,
      color: Color(0xFF2C3E50),
      gradientEnd: Color(0xFF4A6572),
      category: 'Lógica',
      requiredLevel: 9,
    ),
    GameInfo(
      id: 'hangman',
      name: 'Adivina la palabra',
      description: 'Adivina la palabra letra a letra',
      icon: Icons.spellcheck_rounded,
      color: Color(0xFF9B51E0),
      gradientEnd: Color(0xFFB983FF),
      category: 'Palabras',
      requiredLevel: 10,
    ),
    GameInfo(
      id: 'tetris',
      name: 'Tetris',
      description: 'Completa líneas mientras todo cae más rápido',
      icon: Icons.view_module_rounded,
      color: Color(0xFF00BCD4),
      gradientEnd: Color(0xFF4DD0E1),
      category: 'Arcade Pro',
      requiredLevel: 11,
    ),
  ];
}
