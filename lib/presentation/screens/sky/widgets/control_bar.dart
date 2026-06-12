import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../application/fov/active_fov_controller.dart';
import '../../../../application/location/location_controller.dart';
import '../../../../application/sky/solar_system_provider.dart';
import '../../../../application/sky/survey_providers.dart';
import '../../../../application/time/time_controller.dart';
import '../../../../application/viewport/viewport_controller.dart';
import '../../../../domain/models/geo_location.dart';
import '../../equipment/equipment_screen.dart';
import '../../settings/widgets/location_section.dart';
import 'celestial_settings_dialog.dart';
import 'fov_control_section.dart';

/// Bottom control panel (F10/F13).
///
/// Aggregates the time slider, diurnal motion playback, and the Now button,
/// plus icons for display-related settings (celestial settings, time,
/// observing location, FOV, equipment).
/// To avoid rebuilding everything on time updates (100 ms intervals during
/// playback), time-dependent blocks and the settings icons are separated by
/// Consumer boundaries.
/// In single-row mode, place this inside a container with unbounded width
/// (e.g. SingleChildScrollView).
class ControlBar extends StatelessWidget {
  const ControlBar({super.key, this.multiline = false});

  /// If true, wrap all controls across multiple rows instead of relying on
  /// horizontal scrolling (for mobile; the time slider spans the full screen
  /// width).
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    if (multiline) {
      // 3-row layout: row 1 = time slider (as long as possible),
      // row 2 = playback controls + settings icons, row 3 = status
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _TimeSliderRow(expandSlider: true),
          const Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [_PlaybackControls(), _SettingsIcons(wrap: true)],
          ),
          const SizedBox(height: 2),
          const _StatusBlock(),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _TimeSliderRow(),
        _PlaybackControls(),
        _BarDivider(),
        _SettingsIcons(),
        _BarDivider(),
        _StatusBlock(),
      ],
    );
  }
}

TextStyle? _barTextStyle(BuildContext context) => Theme.of(
  context,
).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85));

String _locationLabelOf(AsyncValue<LocationFix> locationAsync) =>
    switch (locationAsync) {
      AsyncData(:final value) => switch (value.source) {
        LocationSource.gps => value.location.name ?? 'Current location',
        LocationSource.manual => value.location.name ?? 'Manual',
        LocationSource.fallback => '${value.location.name ?? "Default"} (default)',
      },
      AsyncError() => 'Location unknown',
      _ => 'Acquiring…',
    };

class _BarDivider extends StatelessWidget {
  const _BarDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 22,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: Colors.white.withValues(alpha: 0.15),
  );
}

/// Time display + time slider (keep the slider: user instruction)
class _TimeSliderRow extends ConsumerWidget {
  const _TimeSliderRow({this.expandSlider = false});

  /// If true, expand the slider to the full available width instead of a
  /// fixed width (for the first row in multi-row mode).
  final bool expandSlider;

  static final _format = DateFormat('MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(timeControllerProvider);
    final local = time.toLocal();
    final hourOfDay = local.hour + local.minute / 60.0 + local.second / 3600.0;
    final textStyle = _barTextStyle(context);

    final slider = Slider(
      value: hourOfDay.clamp(0.0, 23.999),
      min: 0,
      max: 23.999,
      onChanged: (value) {
        ref.read(timePlaybackProvider.notifier).stop();
        final hours = value.floor();
        final minutes = ((value - hours) * 60).round();
        ref
            .read(timeControllerProvider.notifier)
            .setTime(
              DateTime(local.year, local.month, local.day, hours, minutes),
            );
      },
    );

    return Row(
      mainAxisSize: expandSlider ? MainAxisSize.max : MainAxisSize.min,
      children: [
        const Icon(Icons.schedule, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Text(_format.format(local), style: textStyle),
        if (expandSlider)
          Expanded(child: slider)
        else
          SizedBox(width: 170, child: slider),
      ],
    );
  }
}

/// Diurnal motion playback controls (play/speed + Now button)
class _PlaybackControls extends ConsumerWidget {
  const _PlaybackControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackSpeed = ref.watch(timePlaybackProvider);
    final accent = Theme.of(context).colorScheme.primary;
    final textStyle = _barTextStyle(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Play diurnal motion (cycle speed)',
          onPressed: () => ref.read(timePlaybackProvider.notifier).cycleSpeed(),
          icon: Icon(
            playbackSpeed > 0 ? Icons.fast_forward : Icons.play_arrow,
            size: 18,
            color: playbackSpeed > 0 ? accent : Colors.white70,
          ),
        ),
        if (playbackSpeed > 0)
          Text('${playbackSpeed.toInt()}x', style: textStyle),
        TextButton(
          onPressed: () {
            ref.read(timePlaybackProvider.notifier).stop();
            ref.read(timeControllerProvider.notifier).resetToNow();
          },
          child: const Text('Now'),
        ),
      ],
    );
  }
}

/// Settings icons (do not depend on the current time)
class _SettingsIcons extends ConsumerWidget {
  const _SettingsIcons({this.wrap = false});

  /// If true, wrap icons to the next line when width is insufficient (for
  /// multi-row mode).
  final bool wrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveyActive =
        ref.watch(surveySettingsProvider).activeSurveyId != null;
    final fovActive = ref.watch(activeFovProvider).activeSetId != null;

    final icons = <Widget>[
      _ControlIcon(
        icon: Icons.auto_awesome_outlined,
        tooltip: 'Celestial Settings (DSO, Solar System, Survey, Stars, Constellations)',
        // Highlight only while a survey is active (it is the only setting
        // involving network access and caching, so keep its ON state
        // visible at all times)
        active: surveyActive,
        onPressed: () => showCelestialSettingsDialog(context),
      ),
      _ControlIcon(
        icon: Icons.edit_calendar_outlined,
        tooltip: 'Time Settings (date and time)',
        onPressed: () => _showSettingDialog(
          context,
          'Time Settings',
          const _TimeSettingsContent(),
        ),
      ),
      _ControlIcon(
        icon: Icons.place_outlined,
        tooltip: 'Observing Location',
        onPressed: () => _showSettingDialog(
          context,
          'Observing Location',
          const LocationSection(),
        ),
      ),
      _ControlIcon(
        icon: Icons.crop_free,
        tooltip: 'FOV Simulator',
        active: fovActive,
        onPressed: () => _showSettingDialog(
          context,
          'FOV Simulator',
          const FovControlSection(),
        ),
      ),
      _ControlIcon(
        icon: Icons.build_outlined,
        tooltip: 'Equipment',
        onPressed: () => EquipmentScreen.open(context),
      ),
    ];

    if (wrap) {
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: icons,
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }
}

/// Status display (moon age, observing location, FOV angle)
class _StatusBlock extends ConsumerWidget {
  const _StatusBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moonPhase = ref.watch(moonPhaseProvider);
    final locationLabel = _locationLabelOf(
      ref.watch(locationControllerProvider),
    );
    final fovDeg = ref.watch(
      viewportControllerProvider.select((g) => g.fovDeg),
    );
    final textStyle = _barTextStyle(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dark_mode, size: 15, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              'Moon age ${moonPhase.ageDays.toStringAsFixed(1)}',
              style: textStyle,
            ),
          ],
        ),
        Text(locationLabel, style: textStyle),
        Text('FOV ${fovDeg.toStringAsFixed(1)}°', style: textStyle),
      ],
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  /// Whether the feature is active (highlighted with the accent color)
  final bool active;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: active ? accent : Colors.white70),
    );
  }
}

/// Shared settings dialog display (reuses existing section widgets as content)
Future<void> _showSettingDialog(
  BuildContext context,
  String title,
  Widget content,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(child: content),
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

/// Time settings (change date/time and reset)
class _TimeSettingsContent extends ConsumerWidget {
  const _TimeSettingsContent();

  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = ref.watch(timeControllerProvider).toLocal();
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The sky display follows changes to the observation date and time.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_dateFormat.format(local)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: local,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    ref.read(timePlaybackProvider.notifier).stop();
                    ref
                        .read(timeControllerProvider.notifier)
                        .setTime(
                          DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            local.hour,
                            local.minute,
                            local.second,
                          ),
                        );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(_timeFormat.format(local)),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(local),
                  );
                  if (picked != null) {
                    ref.read(timePlaybackProvider.notifier).stop();
                    ref
                        .read(timeControllerProvider.notifier)
                        .setTime(
                          DateTime(
                            local.year,
                            local.month,
                            local.day,
                            picked.hour,
                            picked.minute,
                          ),
                        );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.restore, size: 16),
          label: const Text('Reset to Now'),
          onPressed: () {
            ref.read(timePlaybackProvider.notifier).stop();
            ref.read(timeControllerProvider.notifier).resetToNow();
          },
        ),
      ],
    );
  }
}
