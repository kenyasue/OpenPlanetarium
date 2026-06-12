import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/catalog_download.dart';
import 'settings_persistence.dart';

/// Download mode setting (F4). Persisted.
class DownloadSettingsController extends Notifier<DownloadMode> {
  static const _key = 'download.mode';

  @override
  DownloadMode build() {
    final repo = ref.watch(settingsRepositoryProvider);
    // Prevent delayed writes to a disposed provider
    var disposed = false;
    ref.onDispose(() => disposed = true);
    unawaited(
      repo.read(_key).then((value) {
        if (disposed) return;
        final restored = DownloadMode.values.asNameMap()[value];
        if (restored != null) state = restored;
      }),
    );
    return DownloadMode.wifiOnly;
  }

  void setMode(DownloadMode mode) {
    state = mode;
    unawaited(ref.read(settingsRepositoryProvider).write(_key, mode.name));
  }
}

final downloadSettingsProvider =
    NotifierProvider<DownloadSettingsController, DownloadMode>(
      DownloadSettingsController.new,
    );
