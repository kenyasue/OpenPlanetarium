import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/settings/appearance_settings_controller.dart';
import '../../../../application/settings/dso_settings_controller.dart';
import '../../../../application/settings/solar_system_settings_controller.dart';
import '../../../../domain/appearance/star_appearance.dart';
import '../../../../domain/models/deep_sky_object.dart';
import '../../settings/widgets/survey_settings_section.dart';
import 'constellation_settings_section.dart';

/// Celestial settings dialog (F7/F11 extension).
///
/// Aggregates display-related celestial settings into 5 tabs:
/// DSO / Solar System / Survey / Stars (limiting magnitude, Milky Way) / Constellations
Future<void> showCelestialSettingsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Celestial Settings'),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: const SizedBox(
        width: 460,
        height: 440,
        child: DefaultTabController(
          length: 5,
          child: Column(
            children: [
              TabBar(
                tabAlignment: TabAlignment.fill,
                labelPadding: EdgeInsets.symmetric(horizontal: 4),
                tabs: [
                  Tab(text: 'DSO'),
                  Tab(text: 'Solar System'),
                  Tab(text: 'Survey'),
                  Tab(text: 'Stars'),
                  Tab(text: 'Constellations'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TabContent(child: _DsoTab()),
                    _TabContent(child: _SolarSystemTab()),
                    _TabContent(child: SurveySettingsSection()),
                    _TabContent(child: _StarsTab()),
                    _TabContent(child: ConstellationSettingsSection()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
      child: child,
    );
  }
}

/// DSO tab: per-catalog display on/off
class _DsoTab extends ConsumerWidget {
  const _DsoTab();

  static const _catalogDescriptions = {
    DsoCatalog.messier: 'Messier objects (110 objects)',
    DsoCatalog.ngc: 'NGC (major objects)',
    DsoCatalog.ic: 'IC (major objects)',
    DsoCatalog.sh2: 'Sh2 (HII regions, 313 objects)',
    DsoCatalog.lbn: 'LBN (bright nebulae, 1,125 objects)',
    DsoCatalog.ldn: 'LDN (dark nebulae, 1,787 objects)',
    DsoCatalog.vdb: 'vdB (reflection nebulae, 158 objects)',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(dsoSettingsProvider);
    final controller = ref.read(dsoSettingsProvider.notifier);
    final theme = Theme.of(context);
    final mag = settings.limitingMagnitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the deep-sky object catalogs to display. Messier objects '
          'also belong to NGC and other catalogs, so they are shown if any '
          'of them is enabled.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 4),
        for (final entry in _catalogDescriptions.entries)
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(entry.value, style: theme.textTheme.bodyMedium),
            value: settings.isEnabled(entry.key),
            onChanged: (v) => controller.setCatalog(entry.key, show: v),
          ),
        const Divider(height: 16),
        Text(
          'DSO limiting magnitude: up to ${mag.toStringAsFixed(1)}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        Slider(
          value: mag,
          min: DsoSettings.minLimitingMagnitude,
          max: DsoSettings.maxLimitingMagnitude,
          divisions: 40,
          label: 'Up to mag ${mag.toStringAsFixed(1)}',
          onChanged: controller.setLimitingMagnitude,
        ),
        Text(
          'Objects with unknown magnitude (Sh2/LBN/LDN etc.) follow only the catalog switches.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text('Show object name labels', style: theme.textTheme.bodyMedium),
          subtitle: Text(
            'Brighter objects are labeled first as you zoom (overlaps are culled automatically)',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          value: settings.showLabels,
          onChanged: controller.setShowLabels,
        ),
        Text(
          'Source: OpenNGC (CC-BY-SA-4.0), VizieR VII/20, VII/9, VII/7A, VII/21',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
        ),
      ],
    );
  }
}

/// Solar System tab: display on/off for planets, asteroids, and comets
class _SolarSystemTab extends ConsumerWidget {
  const _SolarSystemTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(solarSystemSettingsProvider);
    final controller = ref.read(solarSystemSettingsProvider.notifier);
    final theme = Theme.of(context);

    Widget tile(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
    ) {
      return SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        value: value,
        onChanged: onChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tile(
          'Planets',
          'Mercury to Neptune (the Sun and Moon are always shown)',
          settings.showPlanets,
          controller.setShowPlanets,
        ),
        tile(
          'Asteroids',
          '129 bright major asteroids (shown up to computed magnitude 12)',
          settings.showAsteroids,
          controller.setShowAsteroids,
        ),
        tile(
          'Comets',
          '120 periodic comets with current orbital elements (shown up to computed magnitude 13)',
          settings.showComets,
          controller.setShowComets,
        ),
        const SizedBox(height: 8),
        Text(
          'Source: JPL Small-Body Database. Positions are approximated by '
          'two-body propagation of Keplerian orbits, and comet magnitudes '
          'vary greatly with activity.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
        ),
      ],
    );
  }
}

/// Stars tab: limiting magnitude and the Milky Way
class _StarsTab extends ConsumerWidget {
  const _StarsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceSettingsProvider);
    final theme = Theme.of(context);
    final mag = settings.userLimitingMagnitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          'Lowering the value approximates the view from urban areas (under '
          'light pollution). The bundled catalog covers up to magnitude 6.5, '
          'and the additional catalog (Tycho-2) up to magnitude 10.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text('Milky Way', style: theme.textTheme.bodyMedium),
          value: settings.showMilkyWay,
          onChanged: (v) =>
              ref.read(appearanceSettingsProvider.notifier).setShowMilkyWay(v),
        ),
      ],
    );
  }
}
