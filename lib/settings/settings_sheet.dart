import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';
import 'app_settings.dart';

/// Gear icon that opens the language / theme sheet. Usable on any screen.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: context.l10n.settings,
      onPressed: () => showSettingsSheet(context),
    );
  }
}

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settings, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(l10n.language, style: titleStyle),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                // Language names are always shown in their own script.
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'bn', label: Text('বাংলা')),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (s) => ref.read(localeProvider.notifier).setLocale(Locale(s.first)),
            ),
            const SizedBox(height: 20),
            Text(l10n.theme, style: titleStyle),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto),
                  label: Text(l10n.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode),
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode),
                  label: Text(l10n.themeDark),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).setThemeMode(s.first),
            ),
          ],
        ),
      ),
    );
  }
}
