import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/sky_object.dart';
import '../../domain/optics/fov_calculator.dart';
import '../selection/selected_object_provider.dart';
import '../settings/settings_persistence.dart';
import 'equipment_providers.dart';

/// State of the FOV frame display (F12). Persisted.
class ActiveFovState {
  const ActiveFovState({
    this.activeSetId,
    this.rotationDeg = 0,
    this.mosaicEnabled = false,
    this.mosaicRows = 2,
    this.mosaicCols = 2,
    this.overlapRatio = 0.2,
  });

  final String? activeSetId;
  final double rotationDeg;
  final bool mosaicEnabled;
  final int mosaicRows;
  final int mosaicCols;
  final double overlapRatio;

  ActiveFovState copyWith({
    String? Function()? activeSetId,
    double? rotationDeg,
    bool? mosaicEnabled,
    int? mosaicRows,
    int? mosaicCols,
    double? overlapRatio,
  }) {
    return ActiveFovState(
      activeSetId: activeSetId != null ? activeSetId() : this.activeSetId,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      mosaicEnabled: mosaicEnabled ?? this.mosaicEnabled,
      mosaicRows: mosaicRows ?? this.mosaicRows,
      mosaicCols: mosaicCols ?? this.mosaicCols,
      overlapRatio: overlapRatio ?? this.overlapRatio,
    );
  }
}

class ActiveFovController extends Notifier<ActiveFovState> {
  static const _key = 'settings.fov';

  @override
  ActiveFovState build() {
    final repo = ref.watch(settingsRepositoryProvider);
    var disposed = false;
    ref.onDispose(() => disposed = true);
    unawaited(
      repo.read(_key).then((value) {
        if (disposed || value == null) return;
        try {
          final json = jsonDecode(value) as Map<String, dynamic>;
          state = ActiveFovState(
            activeSetId: json['setId'] as String?,
            rotationDeg: (json['rotation'] as num?)?.toDouble() ?? 0,
            mosaicEnabled: json['mosaic'] as bool? ?? false,
            mosaicRows: (json['rows'] as num?)?.toInt() ?? 2,
            mosaicCols: (json['cols'] as num?)?.toInt() ?? 2,
            overlapRatio: (json['overlap'] as num?)?.toDouble() ?? 0.2,
          );
        } on FormatException {
          // Continue with defaults if the settings are corrupted
        }
      }),
    );
    return const ActiveFovState();
  }

  void _save() {
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .write(
            _key,
            jsonEncode({
              'setId': state.activeSetId,
              'rotation': state.rotationDeg,
              'mosaic': state.mosaicEnabled,
              'rows': state.mosaicRows,
              'cols': state.mosaicCols,
              'overlap': state.overlapRatio,
            }),
          ),
    );
  }

  void setActiveSet(String? setId) {
    state = state.copyWith(activeSetId: () => setId);
    _save();
  }

  void setRotation(double deg) {
    state = state.copyWith(rotationDeg: deg % 360);
    _save();
  }

  void setMosaicEnabled(bool enabled) {
    state = state.copyWith(mosaicEnabled: enabled);
    _save();
  }

  void setMosaicGrid({int? rows, int? cols}) {
    state = state.copyWith(
      mosaicRows: rows?.clamp(1, 6),
      mosaicCols: cols?.clamp(1, 6),
    );
    _save();
  }

  void setOverlap(double ratio) {
    state = state.copyWith(overlapRatio: ratio.clamp(0.0, 0.5));
    _save();
  }
}

final activeFovProvider = NotifierProvider<ActiveFovController, ActiveFovState>(
  ActiveFovController.new,
);

/// FOV frame precomputed for display.
class FovFrame {
  const FovFrame({
    required this.isCircle,
    required this.widthDeg,
    required this.heightDeg,
    required this.colorArgb,
    required this.label,
  });

  /// Whether this is an eyepiece field of view (circle)
  final bool isCircle;

  final double widthDeg;
  final double heightDeg;
  final int colorArgb;

  /// Frame annotation (e.g. '2.74°×1.86° 2.39"/px')
  final String label;
}

/// Derives the FOV frame from the active equipment set (A5).
final fovFrameProvider = Provider<FovFrame?>((ref) {
  final fovState = ref.watch(activeFovProvider);
  final setId = fovState.activeSetId;
  if (setId == null) return null;

  final sets = ref.watch(equipmentSetsProvider).value ?? const [];
  final set = sets.where((s) => s.id == setId).firstOrNull;
  if (set == null) return null;

  final telescope = (ref.watch(telescopesProvider).value ?? const [])
      .where((t) => t.id == set.telescopeId)
      .firstOrNull;
  if (telescope == null) return null;

  final modifier = set.modifierId == null
      ? null
      : (ref.watch(modifiersProvider).value ?? const [])
            .where((m) => m.id == set.modifierId)
            .firstOrNull;

  if (set.isCameraMode) {
    final camera = (ref.watch(camerasProvider).value ?? const [])
        .where((c) => c.id == set.cameraId)
        .firstOrNull;
    if (camera == null) return null;
    final result = FovCalculator.cameraFov(telescope, camera, modifier);
    return FovFrame(
      isCircle: false,
      widthDeg: result.widthDeg,
      heightDeg: result.heightDeg,
      colorArgb: set.frameColorArgb,
      label:
          '${set.name}  ${result.widthDeg.toStringAsFixed(2)}°×'
          '${result.heightDeg.toStringAsFixed(2)}°  '
          '${result.pixelScaleArcsec.toStringAsFixed(2)}"/px',
    );
  }

  final eyepiece = (ref.watch(eyepiecesProvider).value ?? const [])
      .where((e) => e.id == set.eyepieceId)
      .firstOrNull;
  if (eyepiece == null) return null;
  final result = FovCalculator.eyepieceFov(telescope, eyepiece, modifier);
  return FovFrame(
    isCircle: true,
    widthDeg: result.trueFovDeg,
    heightDeg: result.trueFovDeg,
    colorArgb: set.frameColorArgb,
    label:
        '${set.name}  ${result.magnification.toStringAsFixed(0)}x  '
        'TFOV ${result.trueFovDeg.toStringAsFixed(2)}°  '
        'exit pupil ${result.exitPupilMm.toStringAsFixed(1)}mm',
  );
});

/// Fit check for the selected DSO (F12).
final fovFitProvider = Provider<FitResult?>((ref) {
  final frame = ref.watch(fovFrameProvider);
  final selected = ref.watch(selectedObjectProvider);
  if (frame == null || selected is! DsoObject) return null;
  final major = selected.dso.majorAxisArcmin;
  if (major == null) return null;
  final minor = selected.dso.minorAxisArcmin ?? major;
  return FovCalculator.checkFit(
    frameWidthDeg: frame.widthDeg,
    frameHeightDeg: frame.heightDeg,
    targetMajorDeg: major / 60.0,
    targetMinorDeg: minor / 60.0,
  );
});
