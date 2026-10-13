import 'package:flutter/material.dart';

class ShopItem {
  final String id;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  final int price;

  const ShopItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.gradientEnd,
    required this.price,
  });

  static const List<ShopItem> avatars = [
    ShopItem(
      id: 'avatar_default',
      icon: Icons.person_rounded,
      color: Color(0xFF6C63FF),
      gradientEnd: Color(0xFF8B83FF),
      price: 0,
    ),
    ShopItem(
      id: 'avatar_rocket',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF45B7D1),
      gradientEnd: Color(0xFF6CCFE0),
      price: 60,
    ),
    ShopItem(
      id: 'avatar_star',
      icon: Icons.star_rounded,
      color: Color(0xFFFFBE76),
      gradientEnd: Color(0xFFFFD093),
      price: 100,
    ),
    ShopItem(
      id: 'avatar_flame',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFFF6B6B),
      gradientEnd: Color(0xFFFF8E8E),
      price: 150,
    ),
    ShopItem(
      id: 'avatar_palette',
      icon: Icons.palette_rounded,
      color: Color(0xFFFF6B9D),
      gradientEnd: Color(0xFFFF8FB1),
      price: 220,
    ),
    ShopItem(
      id: 'avatar_martial',
      icon: Icons.sports_martial_arts_rounded,
      color: Color(0xFF4ECDC4),
      gradientEnd: Color(0xFF6EE7DE),
      price: 320,
    ),
    ShopItem(
      id: 'avatar_crown',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFFECA57),
      gradientEnd: Color(0xFFFFD97D),
      price: 450,
    ),
    ShopItem(
      id: 'avatar_diamond',
      icon: Icons.diamond_rounded,
      color: Color(0xFFA29BFE),
      gradientEnd: Color(0xFFBDB8FF),
      price: 650,
    ),
  ];

  static ShopItem get defaultAvatar => avatars.first;

  static ShopItem byId(String id) {
    return avatars.firstWhere((item) => item.id == id, orElse: () => defaultAvatar);
  }
}
