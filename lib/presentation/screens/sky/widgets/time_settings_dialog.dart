import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/time/time_controller.dart';
import '../../../widgets/app_dialog.dart';

/// Opens the time settings dialog (embedded calendar + hour/minute pickers).
Future<void> showTimeSettingsDialog(BuildContext context) {
  return showAppSettingDialog(
    context,
    'Time Settings',
    const TimeSettingsContent(),
    width: 340,
  );
}

/// Time settings body: always-visible calendar for the date plus hour/minute
/// dropdowns. Every change applies to [timeControllerProvider] immediately
/// (the sky follows live) and stops diurnal-motion playback, matching the
/// slider behavior.
class TimeSettingsContent extends ConsumerWidget {
  const TimeSettingsContent({super.key});

  void _apply(WidgetRef ref, DateTime local) {
    ref.read(timePlaybackProvider.notifier).stop();
    ref.read(timeControllerProvider.notifier).setTime(local);
  }

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
        // The calendar sets the date; the time of day is preserved.
        // CalendarDatePicker reads initialDate only in initState, so key it
        // by the observed date: external jumps (Now button, hour dropdown
        // crossing midnight) then rebuild the calendar in sync
        CalendarDatePicker(
          key: ValueKey('${local.year}-${local.month}-${local.day}'),
          initialDate: local,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          onDateChanged: (picked) => _apply(
            ref,
            DateTime(
              picked.year,
              picked.month,
              picked.day,
              local.hour,
              local.minute,
              local.second,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            _TimePartDropdown(
              value: local.hour,
              count: 24,
              onChanged: (hour) => _apply(
                ref,
                DateTime(
                  local.year,
                  local.month,
                  local.day,
                  hour,
                  local.minute,
                  local.second,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(':', style: theme.textTheme.titleMedium),
            ),
            _TimePartDropdown(
              value: local.minute,
              count: 60,
              onChanged: (minute) => _apply(
                ref,
                DateTime(
                  local.year,
                  local.month,
                  local.day,
                  local.hour,
                  minute,
                  local.second,
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.restore, size: 16),
              label: const Text('Now'),
              onPressed: () {
                ref.read(timePlaybackProvider.notifier).stop();
                ref.read(timeControllerProvider.notifier).resetToNow();
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Dropdown for an hour (0-23) or minute (0-59) value, zero-padded.
class _TimePartDropdown extends StatelessWidget {
  const _TimePartDropdown({
    required this.value,
    required this.count,
    required this.onChanged,
  });

  final int value;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: value,
      isDense: true,
      // Long lists (60 minutes) open scrolled to the current selection
      menuMaxHeight: 300,
      items: [
        for (var i = 0; i < count; i++)
          DropdownMenuItem(value: i, child: Text(i.toString().padLeft(2, '0'))),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
