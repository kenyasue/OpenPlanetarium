import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart' show Matrix4;

import '../../application/sky/survey_providers.dart';
import '../../domain/models/survey_layer.dart';
import '../../domain/spatial/healpix.dart';
import 'sky_layer_renderer.dart';

/// Renders HiPS survey tiles (F11).
///
/// Each tile is drawn as a set of textured quads (drawVertices).
/// The subdivision count adapts to the tile's angular size (limits curvature
/// distortion on huge tiles). Tiles containing unprojectable points are still
/// partially drawn using only the projectable quads.
/// Unfetched tiles fall back to a sub-region of an ancestor tile (A6).
class SurveyRenderer implements SkyLayerRenderer {
  SurveyRenderer({
    required this.survey,
    required this.opacity,
    required this.service,
  });

  final SurveyLayerDef survey;
  final double opacity;
  final SurveyTileService service;

  @override
  void render(ui.Canvas canvas, SkyRenderContext context) {
    final order = chooseHipsOrder(context.pxPerDeg, maxOrder: survey.maxOrder);
    final refs = tilesForViewport(
      projection: context.projection,
      state: context.state,
      surveyId: survey.id,
      order: order,
    );

    // Opacity is applied to the whole layer via saveLayer
    final bounds = ui.Offset.zero & context.state.screenSize;
    canvas.saveLayer(
      bounds,
      ui.Paint()
        ..color = const ui.Color(
          0xFFFFFFFF,
        ).withValues(alpha: opacity.clamp(0.0, 1.0)),
    );

    for (final ref in refs) {
      var image = service.imageFor(survey, ref);
      var uvRect = const ui.Rect.fromLTWH(0, 0, 1, 1);

      if (image == null) {
        // Fall back to a sub-region of an ancestor tile (walk up to the nearest fetched order)
        for (var up = 1; up <= ref.order; up++) {
          final ancestorOrder = ref.order - up;
          final (aPix, subX, subY, gridSize) = Healpix.ancestor(
            ref.order,
            ref.pix,
            ancestorOrder,
          );
          final aImage = service.imageFor(
            survey,
            HipsTileRef(surveyId: survey.id, order: ancestorOrder, pix: aPix),
          );
          if (aImage != null) {
            image = aImage;
            // The image coordinate system is (x=fy, y=fx), so swap X/Y for the sub-quadrant too
            uvRect = ui.Rect.fromLTWH(
              subY / gridSize,
              subX / gridSize,
              1 / gridSize,
              1 / gridSize,
            );
            break;
          }
        }
      }
      if (image == null) continue;

      _drawTile(canvas, context, image, ref.order, ref.pix, uvRect);
    }

    canvas.restore();
  }

  /// Subdivision count based on tile angular size (splits 58.6°/2^order into ~4° quads)
  static int _subdivisionsFor(int order) {
    final tileAngularDeg = 58.6 / (1 << order);
    return (tileAngularDeg / 4.0).ceil().clamp(3, 16);
  }

  void _drawTile(
    ui.Canvas canvas,
    SkyRenderContext context,
    ui.Image image,
    int order,
    int pix,
    ui.Rect uvRect,
  ) {
    final n = _subdivisionsFor(order);
    final gridSize = (n + 1) * (n + 1);
    final grid = List<ui.Offset?>.generate(gridSize, (i) {
      final gx = i % (n + 1);
      final gy = i ~/ (n + 1);
      final sky = Healpix.pixGridPoint(order, pix, gx / n, gy / n);
      return context.projection.project(sky);
    });

    // Texture orientation: HiPS tile images map image x=fy / image y=fx
    // (confirmed by matching the actual Norder4/Npix29.jpg image containing M45
    //  against face coordinates: face(0,0)=image top-left, face(0,1)=image top-right,
    //  face(1,0)=image bottom-left).
    ui.Offset uv(double fx, double fy) => ui.Offset(
      (uvRect.left + uvRect.width * fy) * image.width,
      (uvRect.top + uvRect.height * fx) * image.height,
    );

    // Partial drawing that excludes only quads containing unprojectable points
    // (behind the field of view). Vertices are packed with nulls removed, and
    // indices are added only for quads with all 4 vertices present (prevents
    // huge tiles at the FOV boundary from disappearing entirely).
    final vertexIndex = List<int>.filled(gridSize, -1);
    final positions = <ui.Offset>[];
    final texCoords = <ui.Offset>[];
    for (var i = 0; i < gridSize; i++) {
      final pos = grid[i];
      if (pos == null) continue;
      vertexIndex[i] = positions.length;
      positions.add(pos);
      // Same mapping as grid generation: fx = gx/n, fy = gy/n
      texCoords.add(uv((i % (n + 1)) / n, (i ~/ (n + 1)) / n));
    }
    if (positions.length < 4) return;

    final indices = <int>[];
    for (var gy = 0; gy < n; gy++) {
      for (var gx = 0; gx < n; gx++) {
        final i0 = vertexIndex[gy * (n + 1) + gx];
        final i1 = vertexIndex[gy * (n + 1) + gx + 1];
        final i2 = vertexIndex[(gy + 1) * (n + 1) + gx];
        final i3 = vertexIndex[(gy + 1) * (n + 1) + gx + 1];
        if (i0 < 0 || i1 < 0 || i2 < 0 || i3 < 0) continue;
        indices.addAll([i0, i1, i2, i1, i3, i2]);
      }
    }
    if (indices.isEmpty) return;

    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: texCoords,
      indices: indices,
    );
    final paint = ui.Paint()
      ..shader = ui.ImageShader(
        image,
        ui.TileMode.clamp,
        ui.TileMode.clamp,
        Matrix4.identity().storage,
      )
      ..filterQuality = ui.FilterQuality.low;
    canvas.drawVertices(vertices, ui.BlendMode.srcOver, paint);
  }
}
