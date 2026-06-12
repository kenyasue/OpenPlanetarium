import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../application/fov/equipment_providers.dart';
import '../../../domain/models/equipment.dart';
import 'widgets/equipment_forms.dart';

/// Equipment management screen (F12: telescopes, cameras, eyepieces, optical modifiers, equipment sets).
class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({super.key});

  /// Open the equipment management screen. Even when called from a context
  /// inside a dialog, it pushes onto the root Navigator (going back returns
  /// to the dialog).
  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (_) => const EquipmentScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telescopes = ref.watch(telescopesProvider).value ?? const [];
    final cameras = ref.watch(camerasProvider).value ?? const [];
    final eyepieces = ref.watch(eyepiecesProvider).value ?? const [];
    final modifiers = ref.watch(modifiersProvider).value ?? const [];
    final sets = ref.watch(equipmentSetsProvider).value ?? const [];

    Future<void> save(Future<void> Function() action) async {
      await action();
      // Reload list providers (automatically reflected in FOV frames too)
      ref
        ..invalidate(telescopesProvider)
        ..invalidate(camerasProvider)
        ..invalidate(eyepiecesProvider)
        ..invalidate(modifiersProvider)
        ..invalidate(equipmentSetsProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section<EquipmentSet>(
                title: 'Equipment Sets',
                items: sets,
                labelOf: (s) => s.name,
                subtitleOf: (s) {
                  final telescope = telescopes
                      .where((t) => t.id == s.telescopeId)
                      .firstOrNull;
                  final optic = s.isCameraMode
                      ? cameras
                            .where((c) => c.id == s.cameraId)
                            .firstOrNull
                            ?.name
                      : eyepieces
                            .where((e) => e.id == s.eyepieceId)
                            .firstOrNull
                            ?.name;
                  return '${telescope?.name ?? "?"} + ${optic ?? "?"}';
                },
                colorOf: (s) => Color(s.frameColorArgb),
                onAdd:
                    telescopes.isEmpty || (cameras.isEmpty && eyepieces.isEmpty)
                    ? null
                    : () async {
                        final set = await showEquipmentSetDialog(
                          context,
                          telescopes: telescopes,
                          cameras: cameras,
                          eyepieces: eyepieces,
                          modifiers: modifiers,
                        );
                        if (set != null) {
                          await save(
                            () => ref
                                .read(equipmentRepositoryProvider)
                                .saveEquipmentSet(set),
                          );
                        }
                      },
                onEdit: (s) async {
                  final set = await showEquipmentSetDialog(
                    context,
                    telescopes: telescopes,
                    cameras: cameras,
                    eyepieces: eyepieces,
                    modifiers: modifiers,
                    existing: s,
                  );
                  if (set != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveEquipmentSet(set),
                    );
                  }
                },
                onDelete: (s) => save(
                  () => ref
                      .read(equipmentRepositoryProvider)
                      .deleteEquipmentSet(s.id),
                ),
                emptyHint:
                    'Register a telescope and a camera (or eyepiece) to create an equipment set',
              ),
              _Section<Telescope>(
                title: 'Telescopes',
                items: telescopes,
                labelOf: (t) => t.name,
                subtitleOf: (t) =>
                    '${t.type.labelJa}  Aperture ${t.apertureMm.toStringAsFixed(0)}mm'
                    '  FL ${t.focalLengthMm.toStringAsFixed(0)}mm'
                    '  f/${t.fRatio.toStringAsFixed(1)}',
                onAdd: () async {
                  final telescope = await showTelescopeDialog(context);
                  if (telescope != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveTelescope(telescope),
                    );
                  }
                },
                onEdit: (t) async {
                  final telescope = await showTelescopeDialog(
                    context,
                    existing: t,
                  );
                  if (telescope != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveTelescope(telescope),
                    );
                  }
                },
                onDelete: (t) => save(
                  () => ref
                      .read(equipmentRepositoryProvider)
                      .deleteTelescope(t.id),
                ),
              ),
              _Section<CameraDevice>(
                title: 'Cameras',
                items: cameras,
                labelOf: (c) => c.name,
                subtitleOf: (c) =>
                    '${c.sensorWidthMm}×${c.sensorHeightMm}mm  '
                    '${c.pixelSizeUm}µm  ${c.resolutionX}×${c.resolutionY}px',
                onAdd: () async {
                  final camera = await showCameraDialog(context);
                  if (camera != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveCamera(camera),
                    );
                  }
                },
                onEdit: (c) async {
                  final camera = await showCameraDialog(context, existing: c);
                  if (camera != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveCamera(camera),
                    );
                  }
                },
                onDelete: (c) => save(
                  () =>
                      ref.read(equipmentRepositoryProvider).deleteCamera(c.id),
                ),
              ),
              _Section<Eyepiece>(
                title: 'Eyepieces',
                items: eyepieces,
                labelOf: (e) => e.name,
                subtitleOf: (e) =>
                    'FL ${e.focalLengthMm}mm  AFOV ${e.apparentFovDeg}°',
                onAdd: () async {
                  final eyepiece = await showEyepieceDialog(context);
                  if (eyepiece != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveEyepiece(eyepiece),
                    );
                  }
                },
                onEdit: (e) async {
                  final eyepiece = await showEyepieceDialog(
                    context,
                    existing: e,
                  );
                  if (eyepiece != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveEyepiece(eyepiece),
                    );
                  }
                },
                onDelete: (e) => save(
                  () => ref
                      .read(equipmentRepositoryProvider)
                      .deleteEyepiece(e.id),
                ),
              ),
              _Section<OpticalModifier>(
                title: 'Barlows / Reducers',
                items: modifiers,
                labelOf: (m) => m.name,
                subtitleOf: (m) => '${m.kind.labelJa}  ${m.factor}x',
                onAdd: () async {
                  final modifier = await showModifierDialog(context);
                  if (modifier != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveModifier(modifier),
                    );
                  }
                },
                onEdit: (m) async {
                  final modifier = await showModifierDialog(
                    context,
                    existing: m,
                  );
                  if (modifier != null) {
                    await save(
                      () => ref
                          .read(equipmentRepositoryProvider)
                          .saveModifier(modifier),
                    );
                  }
                },
                onDelete: (m) => save(
                  () => ref
                      .read(equipmentRepositoryProvider)
                      .deleteModifier(m.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Insert sample equipment (helper for first-time use)
Future<void> addSampleEquipment(WidgetRef ref) async {
  const uuid = Uuid();
  final repo = ref.read(equipmentRepositoryProvider);
  await repo.saveTelescope(
    Telescope(
      id: uuid.v4(),
      name: 'RASA 8',
      type: TelescopeType.rasa,
      apertureMm: 203,
      focalLengthMm: 400,
    ),
  );
  await repo.saveCamera(
    CameraDevice(
      id: uuid.v4(),
      name: 'ASI294MC Pro',
      sensorWidthMm: 19.1,
      sensorHeightMm: 13.0,
      pixelSizeUm: 4.63,
      resolutionX: 4144,
      resolutionY: 2822,
    ),
  );
}

class _Section<T> extends StatelessWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.subtitleOf,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.colorOf,
    this.emptyHint,
  });

  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final String Function(T) subtitleOf;
  final Color Function(T)? colorOf;
  final VoidCallback? onAdd;
  final void Function(T) onEdit;
  final void Function(T) onDelete;
  final String? emptyHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                tooltip: 'Add',
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                emptyHint ?? 'None registered',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white38,
                ),
              ),
            )
          else
            for (final item in items)
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: colorOf != null
                    ? Icon(Icons.crop_din, size: 16, color: colorOf!(item))
                    : null,
                title: Text(labelOf(item), style: theme.textTheme.bodyMedium),
                subtitle: Text(
                  subtitleOf(item),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: () => onEdit(item),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: () => onDelete(item),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
