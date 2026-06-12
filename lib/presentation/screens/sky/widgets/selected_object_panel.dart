import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../application/location/location_controller.dart';
import '../../../../application/selection/selected_object_provider.dart';
import '../../../../application/time/time_controller.dart';
import '../../../../domain/appearance/star_appearance.dart';
import '../../../../domain/astro/astro_engine.dart';
import '../../../../domain/models/geo_location.dart';
import '../../../../domain/models/sky_object.dart';
import '../../../../domain/models/solar_system.dart';

/// Detail view for the selected object (F9). Shared by the desktop right panel and mobile chip.
class SelectedObjectPanel extends ConsumerWidget {
  const SelectedObjectPanel({super.key, this.compact = false});

  /// If true, single-line display for mobile
  final bool compact;

  static final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final object = ref.watch(selectedObjectProvider);
    final theme = Theme.of(context);

    if (object == null) {
      return Text(
        'Tap / click a celestial object to show its details',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
      );
    }

    final color = switch (object) {
      StarObject(:final star) => StarAppearance.colorOf(star.colorIndexBV),
      DsoObject() => const Color(0xFFC9A9E8),
      SolarBodyObject() => const Color(0xFFF2E3BC),
    };

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            object.magnitude != null
                ? '${object.displayName}  mag ${object.magnitude!.toStringAsFixed(1)}'
                : object.displayName,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => ref.read(selectedObjectProvider.notifier).clear(),
            child: const Icon(Icons.close, size: 14, color: Colors.white54),
          ),
        ],
      );
    }

    final position = ref.watch(selectedObjectPositionProvider);
    final time = ref.watch(timeControllerProvider);
    final location =
        ref.watch(locationControllerProvider).value?.location ??
        GeoLocation.tokyo;

    final rows = <(String, String)>[('Type', object.typeLabel)];
    if (object.magnitude != null && object.magnitude! > -20) {
      rows.add(('Magnitude', object.magnitude!.toStringAsFixed(2)));
    }

    switch (object) {
      case StarObject(:final star):
        if (star.colorIndexBV != null) {
          rows.add(('B-V Index', star.colorIndexBV!.toStringAsFixed(2)));
        }
      case DsoObject(:final dso):
        rows.add(('Catalog', dso.catalogLabel));
        if (dso.constellation != null) {
          rows.add(('Constellation', dso.constellation!));
        }
        if (dso.majorAxisArcmin != null) {
          rows.add((
            'Apparent Size',
            "${dso.majorAxisArcmin!.toStringAsFixed(1)}'"
                "${dso.minorAxisArcmin != null ? " × ${dso.minorAxisArcmin!.toStringAsFixed(1)}'" : ""}",
          ));
        }
      case SolarBodyObject():
        break;
    }

    if (position != null) {
      rows.add((
        'RA / Dec',
        '${position.raDeg.toStringAsFixed(3)}° / '
            '${position.decDeg.toStringAsFixed(3)}°',
      ));

      const astro = AstroEngine();
      final horizontal = astro.equatorialToHorizontal(position, location, time);
      rows.add((
        'Alt / Az',
        '${horizontal.altDeg.toStringAsFixed(1)}° / '
            '${horizontal.azDeg.toStringAsFixed(1)}°',
      ));

      // Rise/set and transit come from a provider recomputed per date
      // (avoids running the 145-sample coordinate transform inside build)
      final riseSet =
          ref.watch(selectedObjectRiseSetProvider) ?? const RiseSetTimes();
      if (riseSet.neverRises) {
        rows.add(('Rise/Set', 'Does not rise on this date'));
      } else {
        if (riseSet.circumpolar) {
          rows.add(('Rise/Set', 'Does not set (circumpolar)'));
        }
        if (riseSet.rise != null) {
          rows.add(('Rise', _timeFormat.format(riseSet.rise!)));
        }
        if (riseSet.transit != null) {
          rows.add(('Transit', _timeFormat.format(riseSet.transit!)));
        }
        if (riseSet.set != null) {
          rows.add(('Set', _timeFormat.format(riseSet.set!)));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                object.displayName,
                style: theme.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              onPressed: () =>
                  ref.read(selectedObjectProvider.notifier).clear(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 84,
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ),
                Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}
