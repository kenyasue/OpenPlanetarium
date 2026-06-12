import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller managing the observation time.
///
/// The state is always held in UTC (converted to local time for display).
class TimeController extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now().toUtc();

  /// Sets the observation time (normalized to UTC for storage)
  void setTime(DateTime time) {
    state = time.toUtc();
  }

  /// Resets to the current time
  void resetToNow() {
    state = DateTime.now().toUtc();
  }

  /// Relative shift (base API for the time slider and diurnal motion)
  void addDuration(Duration delta) {
    state = state.add(delta);
  }
}

final timeControllerProvider = NotifierProvider<TimeController, DateTime>(
  TimeController.new,
);

/// Playback speed of diurnal motion (F10). 0 = stopped, N = N× speed.
///
/// During playback, advances the observation time at 100ms intervals
/// (ephemeris computation for 9 bodies is negligible).
class TimePlaybackController extends Notifier<double> {
  Timer? _timer;

  /// Playback speed cycle (stop → 60× → 600× → 3600× → stop)
  static const speeds = [0.0, 60.0, 600.0, 3600.0];

  @override
  double build() {
    ref.onDispose(() => _timer?.cancel());
    return 0.0;
  }

  void cycleSpeed() {
    final index = speeds.indexOf(state);
    setSpeed(speeds[(index + 1) % speeds.length]);
  }

  void setSpeed(double speed) {
    state = speed;
    _timer?.cancel();
    _timer = null;
    if (speed > 0) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        ref
            .read(timeControllerProvider.notifier)
            .addDuration(Duration(milliseconds: (100 * speed).round()));
      });
    }
  }

  void stop() => setSpeed(0);
}

final timePlaybackProvider = NotifierProvider<TimePlaybackController, double>(
  TimePlaybackController.new,
);
