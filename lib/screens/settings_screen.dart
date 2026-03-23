import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Ajustes', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),

            // Appearance
            Text('Apariencia', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.dark_mode_rounded,
              title: 'Modo oscuro',
              subtitle: provider.isDarkMode ? 'Activado' : 'Desactivado',
              color: AppTheme.primaryLight,
              trailing: Switch.adaptive(
                value: provider.isDarkMode,
                onChanged: (_) => provider.toggleDarkMode(),
                activeTrackColor: AppTheme.primaryLight,
              ),
            ),

            const SizedBox(height: 24),

            // Sound
            Text('Sonido y vibración', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.volume_up_rounded,
              title: 'Sonidos',
              subtitle: provider.soundEnabled ? 'Activados' : 'Desactivados',
              color: AppTheme.success,
              trailing: Switch.adaptive(
                value: provider.soundEnabled,
                onChanged: (_) => provider.toggleSound(),
                activeTrackColor: AppTheme.success,
              ),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.music_note_rounded,
              title: 'Música',
              subtitle: provider.musicEnabled ? 'Activada' : 'Desactivada',
              color: AppTheme.accent,
              trailing: Switch.adaptive(
                value: provider.musicEnabled,
                onChanged: (_) => provider.toggleMusic(),
                activeTrackColor: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.vibration_rounded,
              title: 'Vibración',
              subtitle: provider.hapticEnabled ? 'Activada' : 'Desactivada',
              color: AppTheme.warning,
              trailing: Switch.adaptive(
                value: provider.hapticEnabled,
                onChanged: (_) => provider.toggleHaptic(),
                activeTrackColor: AppTheme.warning,
              ),
            ),

            const SizedBox(height: 24),

            // About
            Text('Acerca de', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Versión',
              subtitle: '1.0.0',
              color: AppTheme.primaryLight,
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.favorite_rounded,
              title: 'Puzless',
              subtitle: 'Hecho con amor para mentes curiosas',
              color: AppTheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (trailing != null) ?trailing,
        ],
      ),
    );
  }
}
