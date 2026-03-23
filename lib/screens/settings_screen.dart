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

            Text('Notas del desarrollador', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _DeveloperNotesCard(theme: theme),

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

class _DeveloperNotesCard extends StatelessWidget {
  final ThemeData theme;

  const _DeveloperNotesCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF231942);
    final bodyColor = isDark
        ? Colors.white.withValues(alpha: 0.84)
        : const Color(0xFF3C355F);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF130F40),
            Color(0xFF6C63FF),
            Color(0xFFFF6B9D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'EDWIN LEDEZMA BY ELEZDEV',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Esta app fue imaginada, diseñada y construida por Edwin Ledezma.',
            style: theme.textTheme.titleLarge?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Puzlessapp es un ritual de neón, lógica e intuición creado para mentes curiosas por ElezDev.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _DeveloperBadge(
                icon: Icons.draw_rounded,
                label: 'Diseño original',
              ),
              _DeveloperBadge(
                icon: Icons.code_rounded,
                label: 'Build by ElezDev',
              ),
              _DeveloperBadge(
                icon: Icons.auto_awesome_rounded,
                label: 'Neon puzzle energy',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeveloperBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DeveloperBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
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
