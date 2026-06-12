import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/viewport/viewport_controller.dart';
import '../../../../domain/astro/astro_engine.dart';

/// Panel that always shows the current coordinates of the view center (top right).
///
/// Displays both altitude/azimuth (AltAz) and RA/Dec, and follows
/// panning, zooming, time changes, and observing location changes.
class CoordinateDisplay extends ConsumerWidget {
  const CoordinateDisplay({super.key});

  static const _engine = AstroEngine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(viewportStateProvider);
    final horizontal = _engine.equatorialToHorizontal(
      viewState.center,
      viewState.location,
      viewState.observationTime,
    );
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white.withValues(alpha: 0.85),
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Alt ${_signedDeg(horizontal.altDeg)}  '
          'Az ${horizontal.azDeg.toStringAsFixed(1)}°',
          style: style,
        ),
        Text(
          'RA ${_formatRaHms(viewState.center.raDeg)}  '
          'Dec ${_formatDecDm(viewState.center.decDeg)}',
          style: style,
        ),
      ],
    );
  }

  static String _signedDeg(double deg) =>
      '${deg < 0 ? "-" : "+"}${deg.abs().toStringAsFixed(1)}°';

  /// RA [deg] → hours-minutes-seconds notation (e.g. 05h34m32s)
  static String _formatRaHms(double raDeg) {
    final totalSeconds = (raDeg / 15.0 * 3600).round() % 86400;
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, "0")}h'
        '${m.toString().padLeft(2, "0")}m'
        '${s.toString().padLeft(2, "0")}s';
  }

  /// Dec [deg] → degrees-minutes notation (e.g. +22°01′)
  static String _formatDecDm(double decDeg) {
    final sign = decDeg < 0 ? '-' : '+';
    final totalMinutes = (decDeg.abs() * 60).round();
    final d = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '$sign${d.toString().padLeft(2, "0")}°'
        '${m.toString().padLeft(2, "0")}′';
  }
}
