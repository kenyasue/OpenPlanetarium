import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/fov/active_fov_controller.dart';
import '../../../application/selection/selected_object_provider.dart';
import '../../../application/settings/appearance_settings_controller.dart';
import '../../../application/settings/constellation_settings_controller.dart';
import '../../../application/settings/dso_settings_controller.dart';
import '../../../application/settings/solar_system_settings_controller.dart';
import '../../../application/sky/constellation_set_provider.dart';
import '../../../application/sky/dso_provider.dart';
import '../../../application/sky/minor_body_provider.dart';
import '../../../application/sky/solar_system_provider.dart';
import '../../../application/sky/survey_providers.dart';
import '../../../application/sky/visible_stars_provider.dart';
import '../../../application/viewport/viewport_controller.dart';
import '../../../domain/models/solar_system.dart';
import '../../../domain/models/star.dart';
import '../../../domain/models/survey_layer.dart';
import '../../painters/background_renderer.dart';
import '../../painters/constellation_renderer.dart';
import '../../painters/dso_renderer.dart';
import '../../painters/fov_frame_renderer.dart';
import '../../painters/grid_renderer.dart';
import '../../painters/ground_renderer.dart';
import '../../painters/horizon_renderer.dart';
import '../../painters/milky_way_renderer.dart';
import '../../painters/minor_body_renderer.dart';
import '../../painters/selection_renderer.dart';
import '../../painters/sky_layer_renderer.dart';
import '../../painters/sky_painter.dart';
import '../../painters/solar_system_renderer.dart';
import '../../painters/star_renderer.dart';
import '../../painters/star_sprite.dart';
import '../../painters/survey_renderer.dart';

/// Sky canvas.
///
/// Controls (docs/product-requirements.md F1):
/// - Mobile: pinch zoom, swipe to pan
/// - Desktop: wheel zoom, drag to pan, arrow/+/- keys
class SkyCanvas extends ConsumerStatefulWidget {
  const SkyCanvas({super.key});

  @override
  ConsumerState<SkyCanvas> createState() => _SkyCanvasState();
}

class _SkyCanvasState extends ConsumerState<SkyCanvas> {
  double _lastScale = 1.0;
  Size? _pendingResize;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final controller = ref.read(viewportControllerProvider.notifier);
    if (details.pointerCount >= 2 && details.scale != 1.0) {
      final factor = details.scale / _lastScale;
      _lastScale = details.scale;
      controller.zoom(factor);
    }
    if (details.focalPointDelta != Offset.zero) {
      controller.pan(details.focalPointDelta);
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // About 1.15x per wheel notch (120px). Zoom focused on the cursor position
      final factor = math.pow(1.15, -event.scrollDelta.dy / 120.0).toDouble();
      ref
          .read(viewportControllerProvider.notifier)
          .zoom(factor, focalPoint: event.localPosition);
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final controller = ref.read(viewportControllerProvider.notifier);
    final size = ref.read(viewportControllerProvider).screenSize;
    final panStep = size.shortestSide * 0.08;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        controller.pan(Offset(panStep, 0));
      case LogicalKeyboardKey.arrowRight:
        controller.pan(Offset(-panStep, 0));
      case LogicalKeyboardKey.arrowUp:
        controller.pan(Offset(0, panStep));
      case LogicalKeyboardKey.arrowDown:
        controller.pan(Offset(0, -panStep));
      case LogicalKeyboardKey.equal:
      case LogicalKeyboardKey.add:
      case LogicalKeyboardKey.numpadAdd:
        controller.zoom(1.25);
      case LogicalKeyboardKey.minus:
      case LogicalKeyboardKey.numpadSubtract:
        controller.zoom(0.8);
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _onTapUp(TapUpDetails details) {
    _focusNode.requestFocus();
    ref
        .read(selectedObjectProvider.notifier)
        .selectAtScreenPoint(details.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    // Notify the user instead of silently ignoring catalog load failures
    // (corruption etc.). Rendering continues with loaded data (or no stars)
    ref.listen(visibleStarsProvider, (previous, next) {
      if (next.hasError && !next.isLoading && !(previous?.hasError ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load star data. Try restarting the app or re-downloading the data.'),
          ),
        );
      }
    });
    ref.listen(minorBodyListProvider, (previous, next) {
      if (next.hasError && !next.isLoading && !(previous?.hasError ?? false)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text('Failed to load minor body data.')),
        );
      }
    });

    final state = ref.watch(viewportStateProvider);
    final stars = ref.watch(visibleStarsProvider).value ?? const <Star>[];
    final settings = ref.watch(appearanceSettingsProvider);
    final sprite = ref.watch(starSpriteProvider).value;
    final constellationSet = ref.watch(constellationSetProvider).value;
    final constellationSettings = ref.watch(constellationSettingsProvider);
    final dsos = ref.watch(visibleDsosProvider);
    final solarSettings = ref.watch(solarSystemSettingsProvider);
    final allSolarBodies = ref.watch(solarSystemProvider);
    // Keep the Sun and Moon visible as fundamental sky elements even when planets are off
    final solarBodies = solarSettings.showPlanets
        ? allSolarBodies
        : [
            for (final b in allSolarBodies)
              if (b.body == SolarBodyId.sun || b.body == SolarBodyId.moon) b,
          ];
    final minorBodies = ref.watch(visibleMinorBodiesProvider);
    final sunPosition = allSolarBodies
        .firstWhere((b) => b.body == SolarBodyId.sun)
        .position;
    final moonPhase = ref.watch(moonPhaseProvider);
    final selectedPosition = ref.watch(selectedObjectPositionProvider);
    final surveySettings = ref.watch(surveySettingsProvider);
    final fovFrame = ref.watch(fovFrameProvider);
    ref.watch(tileVersionProvider); // Repaint when tiles arrive
    final activeSurvey = surveySettings.activeSurveyId == null
        ? null
        : kBuiltinSurveys
              .where((s) => s.id == surveySettings.activeSurveyId)
              .firstOrNull;

    // Draw order: background → survey → Milky Way → grid → constellations →
    // DSO → stars → solar system → ground fill → horizon → FOV frame →
    // selection ring (objects below the horizon are dimmed by the
    // semi-transparent ground; the horizon line and direction labels stay on top)
    final layers = <SkyLayerRenderer>[
      const BackgroundRenderer(),
      if (activeSurvey != null)
        SurveyRenderer(
          survey: activeSurvey,
          opacity: surveySettings.opacity,
          service: ref.watch(surveyTileServiceProvider),
        ),
      if (settings.showMilkyWay) const MilkyWayRenderer(),
      const GridRenderer(),
      if (constellationSet != null)
        ConstellationRenderer(
          set: constellationSet,
          settings: constellationSettings,
        ),
      DsoRenderer(
        dsos: dsos,
        showLabels: ref.watch(dsoSettingsProvider.select((s) => s.showLabels)),
      ),
      StarRenderer(stars: stars, settings: settings, sprite: sprite),
      SolarSystemRenderer(bodies: solarBodies, moonPhase: moonPhase),
      if (minorBodies.isNotEmpty)
        MinorBodyRenderer(bodies: minorBodies, sunPosition: sunPosition),
      const GroundRenderer(),
      const HorizonRenderer(),
      if (fovFrame != null)
        FovFrameRenderer(
          frame: fovFrame,
          fovState: ref.watch(activeFovProvider),
          center: selectedPosition ?? state.center,
        ),
      if (selectedPosition != null) SelectionRenderer(target: selectedPosition),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size != state.screenSize &&
            !size.isEmpty &&
            _pendingResize != size) {
          // Prevent registering multiple callbacks for the same size
          _pendingResize = size;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pendingResize = null;
            if (mounted) {
              ref.read(viewportControllerProvider.notifier).resize(size);
            }
          });
        }
        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _onKeyEvent,
          child: Listener(
            onPointerSignal: _onPointerSignal,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onTapUp: _onTapUp,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: size,
                  painter: SkyPainter(state: state, layers: layers),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
