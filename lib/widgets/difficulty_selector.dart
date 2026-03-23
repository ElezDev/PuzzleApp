import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../l10n/app_strings.dart';

class DifficultySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final List<String> difficulties;

  const DifficultySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.difficulties = const ['Fácil', 'Medio', 'Difícil'],
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: difficulties.map((d) {
        final isSelected = d == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: ChoiceChip(
              label: Text(strings.difficultyLabel(d)),
              selected: isSelected,
              onSelected: (_) => onChanged(d),
              selectedColor: AppTheme.primaryLight,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        );
      }).toList(),
    );
  }
}
