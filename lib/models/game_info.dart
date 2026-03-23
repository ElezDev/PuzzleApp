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

  const GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradientEnd,
    required this.category,
    this.supportsMultiplayer = false,
  });

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
    ),
    GameInfo(
      id: 'memory',
      name: 'Memoria',
      description: 'Encuentra los pares ocultos',
      icon: Icons.psychology_rounded,
      color: Color(0xFFFF6B9D),
      gradientEnd: Color(0xFFFF8FB1),
      category: 'Memoria',
    ),
    GameInfo(
      id: 'slide_puzzle',
      name: 'Deslizar',
      description: 'Ordena las piezas deslizando',
      icon: Icons.view_comfy_rounded,
      color: Color(0xFF4ECDC4),
      gradientEnd: Color(0xFF6EE7DE),
      category: 'Lógica',
    ),
    GameInfo(
      id: 'pattern',
      name: 'Patrones',
      description: 'Repite la secuencia de colores',
      icon: Icons.palette_rounded,
      color: Color(0xFFFFBE76),
      gradientEnd: Color(0xFFFFD093),
      category: 'Memoria',
    ),
    GameInfo(
      id: 'sudoku',
      name: 'Sudoku',
      description: 'Completa la cuadrícula numérica',
      icon: Icons.apps_rounded,
      color: Color(0xFF45B7D1),
      gradientEnd: Color(0xFF6CCFE0),
      category: 'Lógica',
    ),
    GameInfo(
      id: 'color_match',
      name: 'Color Match',
      description: 'Acierta el color correcto',
      icon: Icons.colorize_rounded,
      color: Color(0xFFFF6B6B),
      gradientEnd: Color(0xFFFF8E8E),
      category: 'Reflejos',
    ),
  ];
}
