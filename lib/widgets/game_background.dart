import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

/// Paints the background equipped for a specific screen [slot] behind [child].
/// When no override is set for the slot, [child] is returned untouched so the
/// global app background remains visible.
class GameBackground extends StatelessWidget {
  final String slot;
  final Widget child;

  const GameBackground({super.key, required this.slot, required this.child});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final background = provider.backgroundFor(slot);
    if (background == null) return child;

    final colors = provider.isDarkMode
        ? background.darkColors
        : background.lightColors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
