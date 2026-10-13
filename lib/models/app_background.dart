import 'package:flutter/material.dart';

class AppBackground {
  final String id;
  final List<Color> lightColors;
  final List<Color> darkColors;
  final int price;

  const AppBackground({
    required this.id,
    required this.lightColors,
    required this.darkColors,
    required this.price,
  });

  static const List<AppBackground> all = [
    AppBackground(
      id: 'bg_default',
      lightColors: [Color(0xFFF0F1FA), Color(0xFFE8EAF7)],
      darkColors: [Color(0xFF12131E), Color(0xFF1A1B2E)],
      price: 0,
    ),
    AppBackground(
      id: 'bg_sunset',
      lightColors: [Color(0xFFFFE8D6), Color(0xFFFFD6E8)],
      darkColors: [Color(0xFF3A1F2B), Color(0xFF241326)],
      price: 80,
    ),
    AppBackground(
      id: 'bg_ocean',
      lightColors: [Color(0xFFD6F0FF), Color(0xFFE0E8FF)],
      darkColors: [Color(0xFF0F2233), Color(0xFF12203A)],
      price: 120,
    ),
    AppBackground(
      id: 'bg_forest',
      lightColors: [Color(0xFFDFF5E1), Color(0xFFEAF7E6)],
      darkColors: [Color(0xFF12261A), Color(0xFF0F1E16)],
      price: 160,
    ),
    AppBackground(
      id: 'bg_midnight',
      lightColors: [Color(0xFFE4E0FF), Color(0xFFF0E6FF)],
      darkColors: [Color(0xFF1A1440), Color(0xFF0D0A24)],
      price: 220,
    ),
    AppBackground(
      id: 'bg_neon',
      lightColors: [Color(0xFFFFE0F5), Color(0xFFE0F0FF)],
      darkColors: [Color(0xFF2A0A3A), Color(0xFF0A1A3A)],
      price: 320,
    ),
    AppBackground(
      id: 'bg_galaxy',
      lightColors: [Color(0xFFE8E0FF), Color(0xFFD8E4FF)],
      darkColors: [Color(0xFF140B2E), Color(0xFF0A0820)],
      price: 450,
    ),
  ];

  static AppBackground get defaultBackground => all.first;

  static AppBackground byId(String id) {
    return all.firstWhere(
      (item) => item.id == id,
      orElse: () => defaultBackground,
    );
  }
}
