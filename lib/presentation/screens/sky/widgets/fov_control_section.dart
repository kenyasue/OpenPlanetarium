import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/fov/active_fov_controller.dart';
import '../../../../application/fov/equipment_providers.dart';
import '../../../../domain/optics/fov_calculator.dart';
import '../../equipment/equipment_screen.dart';

/// FOV frame controls (F12: set selection, rotation, mosaic, fit check).
class FovControlSection extends ConsumerWidget {
  const FovControlSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fovState = ref.watch(activeFovProvider);
    final controller = ref.read(activeFovProvider.notifier);
    final sets = ref.watch(equipmentSetsProvider).value ?? const [];
    final fit = ref.watch(fovFitProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('FOV Simulator', style: theme.textTheme.titleSmall),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              tooltip: 'Equipment',
              onPressed: () => EquipmentScreen.open(context),
              icon: const Icon(Icons.build_outlined),
            ),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String?>(
          initialValue: fovState.activeSetId,
          decoration: const InputDecoration(
            labelText: 'Equipment Set',
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Hidden')),
            for (final set in sets)
              DropdownMenuItem(value: set.id, child: Text(set.name)),
          ],
          onChanged: controller.setActiveSet,
        ),
        if (fovState.activeSetId != null) ...[
          const SizedBox(height: 4),
          Text(
            'Rotation ${fovState.rotationDeg.toStringAsFixed(0)}°',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          Slider(
            value: fovState.rotationDeg,
            min: 0,
            max: 359,
            onChanged: controller.setRotation,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mosaic', style: theme.textTheme.bodySmall),
              Switch(
                value: fovState.mosaicEnabled,
                onChanged: controller.setMosaicEnabled,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          if (fovState.mosaicEnabled) ...[
            Row(
              children: [
                _Stepper(
                  label: 'Rows',
                  value: fovState.mosaicRows,
                  onChanged: (v) => controller.setMosaicGrid(rows: v),
                ),
                const SizedBox(width: 12),
                _Stepper(
                  label: 'Cols',
                  value: fovState.mosaicCols,
                  onChanged: (v) => controller.setMosaicGrid(cols: v),
                ),
              ],
            ),
            Text(
              'Overlap ${(fovState.overlapRatio * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            Slider(
              value: fovState.overlapRatio,
              min: 0,
              max: 0.5,
              onChanged: controller.setOverlap,
            ),
          ],
          if (fit != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: switch (fit) {
                  FitResult.fits => Colors.green.withValues(alpha: 0.15),
                  FitResult.tight => Colors.orange.withValues(alpha: 0.15),
                  FitResult.overflow => Colors.red.withValues(alpha: 0.15),
                },
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(switch (fit) {
                FitResult.fits => 'Selected object fits within the field of view',
                FitResult.tight => 'Barely fits (watch your framing)',
                FitResult.overflow => 'Does not fit. Mosaic imaging recommended',
              }, style: theme.textTheme.bodySmall),
            ),
        ],
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 16,
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Text('$value'),
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 16,
          onPressed: value < 6 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
