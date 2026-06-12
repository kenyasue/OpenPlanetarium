import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/constellation_data.dart';
import 'settings_persistence.dart';

/// Constellation display settings (F6).
class ConstellationSettings {
  const ConstellationSettings({
    this.showLines = true,
    this.showNames = true,
    this.showBoundaries = false,
    this.lineOpacity = 0.35,
    this.lineWidth = 1.0,
    this.language = NameLanguage.japanese,
  });

  final bool showLines;
  final bool showNames;
  final bool showBoundaries;

  /// Line opacity 0.05-1.0
  final double lineOpacity;

  /// Line width [px] 0.5-3.0
  final double lineWidth;

  final NameLanguage language;

  ConstellationSettings copyWith({
    bool? showLines,
    bool? showNames,
    bool? showBoundaries,
    double? lineOpacity,
    double? lineWidth,
    NameLanguage? language,
  }) {
    return ConstellationSettings(
      showLines: showLines ?? this.showLines,
      showNames: showNames ?? this.showNames,
      showBoundaries: showBoundaries ?? this.showBoundaries,
      lineOpacity: lineOpacity ?? this.lineOpacity,
      lineWidth: lineWidth ?? this.lineWidth,
      language: language ?? this.language,
    );
  }
}

class ConstellationSettingsController extends Notifier<ConstellationSettings> {
  static const _key = 'settings.constellation';

  @override
  ConstellationSettings build() {
    final repo = ref.watch(settingsRepositoryProvider);
    // Prevent delayed writes to a disposed provider
    var disposed = false;
    ref.onDispose(() => disposed = true);
    unawaited(
      repo.read(_key).then((value) {
        if (disposed || value == null) return;
        try {
          state = _fromJson(jsonDecode(value) as Map<String, dynamic>);
        } on FormatException {
          // Continue with defaults if the settings are corrupted
        }
      }),
    );
    return const ConstellationSettings();
  }

  void _save() {
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .write(_key, jsonEncode(_toJson(state))),
    );
  }

  void setShowLines(bool value) {
    state = state.copyWith(showLines: value);
    _save();
  }

  void setShowNames(bool value) {
    state = state.copyWith(showNames: value);
    _save();
  }

  void setShowBoundaries(bool value) {
    state = state.copyWith(showBoundaries: value);
    _save();
  }

  void setLineOpacity(double value) {
    state = state.copyWith(lineOpacity: value.clamp(0.05, 1.0));
    _save();
  }

  void setLineWidth(double value) {
    state = state.copyWith(lineWidth: value.clamp(0.5, 3.0));
    _save();
  }

  void setLanguage(NameLanguage value) {
    state = state.copyWith(language: value);
    _save();
  }

  static Map<String, dynamic> _toJson(ConstellationSettings s) => {
    'showLines': s.showLines,
    'showNames': s.showNames,
    'showBoundaries': s.showBoundaries,
    'lineOpacity': s.lineOpacity,
    'lineWidth': s.lineWidth,
    'language': s.language.name,
  };

  static ConstellationSettings _fromJson(Map<String, dynamic> json) {
    return ConstellationSettings(
      showLines: json['showLines'] as bool? ?? true,
      showNames: json['showNames'] as bool? ?? true,
      showBoundaries: json['showBoundaries'] as bool? ?? false,
      lineOpacity: (json['lineOpacity'] as num?)?.toDouble() ?? 0.35,
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 1.0,
      language:
          NameLanguage.values.asNameMap()[json['language']] ??
          NameLanguage.japanese,
    );
  }
}

final constellationSettingsProvider =
    NotifierProvider<ConstellationSettingsController, ConstellationSettings>(
      ConstellationSettingsController.new,
    );
