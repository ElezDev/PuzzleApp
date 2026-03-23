import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/app_theme.dart';
import '../l10n/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(strings.settings, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),

            // Appearance
            Text(strings.appearance, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.dark_mode_rounded,
              title: strings.darkMode,
              subtitle: provider.isDarkMode ? strings.on : strings.off,
              color: AppTheme.primaryLight,
              trailing: Switch.adaptive(
                value: provider.isDarkMode,
                onChanged: (_) => provider.toggleDarkMode(),
                activeTrackColor: AppTheme.primaryLight,
              ),
            ),

            const SizedBox(height: 24),

            Text(strings.language, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.language_rounded,
              title: strings.language,
              subtitle: provider.languageCode == 'system'
                  ? strings.useSystemLanguage
                  : strings.languageLabel(provider.languageCode),
              color: AppTheme.primaryLight,
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: provider.languageCode,
                  borderRadius: BorderRadius.circular(16),
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(strings.systemDefault),
                    ),
                    DropdownMenuItem(
                      value: 'es',
                      child: Text(strings.spanish),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(strings.english),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setLanguage(value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sound
            Text(strings.soundAndVibration, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.volume_up_rounded,
              title: strings.sounds,
              subtitle: provider.soundEnabled ? strings.on : strings.off,
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
              title: strings.music,
              subtitle: provider.musicEnabled ? strings.on : strings.off,
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
              title: strings.vibration,
              subtitle: provider.hapticEnabled ? strings.on : strings.off,
              color: AppTheme.warning,
              trailing: Switch.adaptive(
                value: provider.hapticEnabled,
                onChanged: (_) => provider.toggleHaptic(),
                activeTrackColor: AppTheme.warning,
              ),
            ),

            const SizedBox(height: 24),

            Text(strings.developerNotes, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _DeveloperNotesCard(theme: theme, strings: strings),

            const SizedBox(height: 24),

            // About
            Text(strings.about, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: strings.version,
              subtitle: '1.0.0',
              color: AppTheme.primaryLight,
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.favorite_rounded,
              title: 'Puzless',
              subtitle: strings.madeForCuriousMinds,
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
  final AppStrings strings;

  const _DeveloperNotesCard({required this.theme, required this.strings});

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
              strings.developerSignature,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            strings.developerCardTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            strings.developerCardBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DeveloperBadge(
                icon: Icons.draw_rounded,
                label: strings.developerBadgeDesign,
              ),
              _DeveloperBadge(
                icon: Icons.code_rounded,
                label: strings.developerBadgeBuild,
              ),
              _DeveloperBadge(
                icon: Icons.auto_awesome_rounded,
                label: strings.developerBadgeEnergy,
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
          ...switch (trailing) {
            final widget? => [widget],
            null => const <Widget>[],
          },
        ],
      ),
    );
  }
}
