import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/settings/constellation_settings_controller.dart';
import '../../../../domain/models/constellation_data.dart';

/// Constellation display settings section (F6).
class ConstellationSettingsSection extends ConsumerWidget {
  const ConstellationSettingsSection({super.key});

  static const _languageLabels = {
    NameLanguage.japanese: 'Japanese',
    NameLanguage.english: 'English',
    NameLanguage.latin: 'Latin',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(constellationSettingsProvider);
    final controller = ref.read(constellationSettingsProvider.notifier);
    final theme = Theme.of(context);

    Widget toggle(String label, bool value, ValueChanged<bool> onChanged) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Constellation Display', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        toggle('Constellation Lines', settings.showLines, controller.setShowLines),
        toggle('Constellation Names', settings.showNames, controller.setShowNames),
        toggle('Constellation Boundaries', settings.showBoundaries, controller.setShowBoundaries),
        const SizedBox(height: 4),
        Text(
          'Line Opacity',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        Slider(
          value: settings.lineOpacity,
          min: 0.05,
          max: 1.0,
          onChanged: controller.setLineOpacity,
        ),
        Text(
          'Line Width',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        Slider(
          value: settings.lineWidth,
          min: 0.5,
          max: 3.0,
          onChanged: controller.setLineWidth,
        ),
        Text(
          'Constellation Name Language',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        SegmentedButton<NameLanguage>(
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11)),
          ),
          segments: [
            for (final lang in NameLanguage.values)
              ButtonSegment(value: lang, label: Text(_languageLabels[lang]!)),
          ],
          selected: {settings.language},
          onSelectionChanged: (selection) =>
              controller.setLanguage(selection.first),
        ),
      ],
    );
  }
}
