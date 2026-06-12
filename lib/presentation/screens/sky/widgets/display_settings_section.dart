import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/settings/appearance_settings_controller.dart';
import '../../../../domain/appearance/star_appearance.dart';

/// Display settings section (limiting magnitude, Milky Way).
class DisplaySettingsSection extends ConsumerWidget {
  const DisplaySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceSettingsProvider);
    final theme = Theme.of(context);
    final mag = settings.userLimitingMagnitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Settings', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Show stars up to magnitude ${mag.toStringAsFixed(1)}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        Slider(
          value: mag,
          min: AppearanceSettings.minLimitingMagnitude,
          max: AppearanceSettings.maxLimitingMagnitude,
          divisions: 38,
          label: 'Up to mag ${mag.toStringAsFixed(1)}',
          onChanged: (value) => ref
              .read(appearanceSettingsProvider.notifier)
              .setLimitingMagnitude(value),
        ),
        Text(
          'Lowering the value approximates the view from urban areas (under light pollution).',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Milky Way', style: theme.textTheme.bodySmall),
            Switch(
              value: settings.showMilkyWay,
              onChanged: (v) => ref
                  .read(appearanceSettingsProvider.notifier)
                  .setShowMilkyWay(v),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ],
    );
  }
}
