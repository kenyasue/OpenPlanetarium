import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/sky/survey_providers.dart';
import '../../../../domain/models/survey_layer.dart';

/// Survey data settings section (F11: exclusive toggle for 4 DSS layers and opacity).
class SurveySettingsSection extends ConsumerStatefulWidget {
  const SurveySettingsSection({super.key});

  @override
  ConsumerState<SurveySettingsSection> createState() =>
      _SurveySettingsSectionState();
}

class _SurveySettingsSectionState extends ConsumerState<SurveySettingsSection> {
  /// Completion message for cache deletion (inline display, safe inside dialogs)
  String? _statusText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(surveySettingsProvider);
    final controller = ref.read(surveySettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Survey Data', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Overlays astronomical survey imagery (DSS) on the sky chart '
          'background. Tiles are fetched on demand and cached (only cached '
          'tiles are shown while offline).',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: const Text('None'),
              selected: settings.activeSurveyId == null,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => controller.setActiveSurvey(null),
            ),
            for (final survey in kBuiltinSurveys)
              ChoiceChip(
                label: Text(survey.name),
                selected: settings.activeSurveyId == survey.id,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => controller.setActiveSurvey(survey.id),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Opacity',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        Slider(
          value: settings.opacity,
          min: 0.05,
          max: 1.0,
          onChanged: controller.setOpacity,
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () async {
                await ref.read(surveyTileServiceProvider).clearCache();
                if (mounted) {
                  setState(() => _statusText = 'Survey cache deleted');
                }
              },
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Clear Cache'),
            ),
            if (_statusText != null)
              Expanded(
                child: Text(
                  _statusText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        if (settings.activeSurveyId != null)
          Text(
            'Source: ${kBuiltinSurveys.where((s) => s.id == settings.activeSurveyId).firstOrNull?.attribution ?? ""}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
          ),
      ],
    );
  }
}
