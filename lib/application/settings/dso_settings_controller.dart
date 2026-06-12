import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/deep_sky_object.dart';
import 'settings_persistence.dart';

/// DSO display settings (per-catalog on/off, display magnitude, labels; F7).
class DsoSettings {
  const DsoSettings({
    this.enabled = defaultEnabled,
    this.limitingMagnitude = defaultLimitingMagnitude,
    this.showLabels = true,
  });

  /// Catalogs shown by default. Faint nebula catalogs (Sh2/LBN/LDN/vdB) have
  /// many entries and sparse magnitude data, so they must be enabled explicitly.
  /// `other` (uncategorized such as Melotte) is always shown and not exposed in the settings UI
  static const Set<DsoCatalog> defaultEnabled = {
    DsoCatalog.messier,
    DsoCatalog.ngc,
    DsoCatalog.ic,
    DsoCatalog.other,
  };

  /// Range and default of the DSO display magnitude setting (matches the bundled catalog's upper limit)
  static const double minLimitingMagnitude = 0.0;
  static const double maxLimitingMagnitude = 20.0;
  static const double defaultLimitingMagnitude = 20.0;

  final Set<DsoCatalog> enabled;

  /// Hides DSOs fainter than this magnitude.
  /// Objects with unknown magnitude (Sh2/LBN/LDN etc.) follow the catalog switches only
  final double limitingMagnitude;

  /// Shows DSO name labels on the celestial sphere (overlaps are automatically thinned)
  final bool showLabels;

  bool isEnabled(DsoCatalog catalog) => enabled.contains(catalog);

  DsoSettings copyWith({
    Set<DsoCatalog>? enabled,
    double? limitingMagnitude,
    bool? showLabels,
  }) {
    return DsoSettings(
      enabled: enabled ?? this.enabled,
      limitingMagnitude: limitingMagnitude ?? this.limitingMagnitude,
      showLabels: showLabels ?? this.showLabels,
    );
  }

  DsoSettings withCatalog(DsoCatalog catalog, {required bool show}) {
    final next = {...enabled};
    show ? next.add(catalog) : next.remove(catalog);
    return copyWith(enabled: next);
  }
}

/// Controller managing DSO display settings. Persisted.
class DsoSettingsController extends Notifier<DsoSettings> {
  static const _key = 'settings.dso';

  @override
  DsoSettings build() {
    final repo = ref.watch(settingsRepositoryProvider);
    var disposed = false;
    ref.onDispose(() => disposed = true);
    unawaited(
      repo.read(_key).then((value) {
        if (disposed || value == null) return;
        try {
          final json = jsonDecode(value) as Map<String, dynamic>;
          final names = (json['enabled'] as List<dynamic>).cast<String>();
          state = DsoSettings(
            enabled: {
              for (final name in names)
                if (DsoCatalog.values.asNameMap()[name] != null)
                  DsoCatalog.values.asNameMap()[name]!,
            },
            limitingMagnitude:
                (json['limitingMagnitude'] as num?)?.toDouble() ??
                DsoSettings.defaultLimitingMagnitude,
            showLabels: json['showLabels'] as bool? ?? true,
          );
        } on FormatException {
          // Continue with defaults if the settings are corrupted
        }
      }),
    );
    return const DsoSettings();
  }

  void setCatalog(DsoCatalog catalog, {required bool show}) {
    _update(state.withCatalog(catalog, show: show));
  }

  /// Sets the DSO display magnitude (objects fainter than this are hidden)
  void setLimitingMagnitude(double magnitude) {
    _update(
      state.copyWith(
        limitingMagnitude: magnitude.clamp(
          DsoSettings.minLimitingMagnitude,
          DsoSettings.maxLimitingMagnitude,
        ),
      ),
    );
  }

  void setShowLabels(bool show) {
    _update(state.copyWith(showLabels: show));
  }

  void _update(DsoSettings next) {
    state = next;
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .write(
            _key,
            jsonEncode({
              'enabled': [for (final c in next.enabled) c.name],
              'limitingMagnitude': next.limitingMagnitude,
              'showLabels': next.showLabels,
            }),
          ),
    );
  }
}

final dsoSettingsProvider =
    NotifierProvider<DsoSettingsController, DsoSettings>(
      DsoSettingsController.new,
    );
