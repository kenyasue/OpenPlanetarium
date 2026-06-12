import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/location/location_controller.dart';
import '../../../../domain/models/geo_location.dart';

/// Observing location section (manual position, city presets, GPS refresh).
class LocationSection extends ConsumerStatefulWidget {
  const LocationSection({super.key});

  @override
  ConsumerState<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends ConsumerState<LocationSection> {
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  /// Input error (shown inline so it works inside dialogs too;
  /// ScaffoldMessenger cannot be safely referenced from a dialog context)
  String? _errorText;

  static const _presets = [
    GeoLocation(latitudeDeg: 35.6812, longitudeDeg: 139.7671, name: 'Tokyo'),
    GeoLocation(latitudeDeg: 34.6937, longitudeDeg: 135.5023, name: 'Osaka'),
    GeoLocation(latitudeDeg: 43.0618, longitudeDeg: 141.3545, name: 'Sapporo'),
    GeoLocation(latitudeDeg: 33.5904, longitudeDeg: 130.4017, name: 'Fukuoka'),
    GeoLocation(latitudeDeg: 26.2124, longitudeDeg: 127.6809, name: 'Naha'),
  ];

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _applyManual() {
    final lat = double.tryParse(_latController.text);
    final lon = double.tryParse(_lonController.text);
    if (lat == null || lat < -90 || lat > 90) {
      setState(() => _errorText = 'Latitude must be a number between -90 and 90');
      return;
    }
    if (lon == null || lon < -180 || lon > 180) {
      setState(() => _errorText = 'Longitude must be a number between -180 and 180');
      return;
    }
    setState(() => _errorText = null);
    ref
        .read(locationControllerProvider.notifier)
        .setManualLocation(
          GeoLocation(latitudeDeg: lat, longitudeDeg: lon, name: 'Manual'),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fix = ref.watch(locationControllerProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Observing Location', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (fix != null)
          Text(
            'Current: ${fix.location.name ?? "Unknown"} '
            '(${fix.location.latitudeDeg.toStringAsFixed(4)}, '
            '${fix.location.longitudeDeg.toStringAsFixed(4)})',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final preset in _presets)
              ActionChip(
                label: Text(preset.name!),
                visualDensity: VisualDensity.compact,
                onPressed: () => ref
                    .read(locationControllerProvider.notifier)
                    .setManualLocation(preset),
              ),
            ActionChip(
              avatar: const Icon(Icons.my_location, size: 14),
              label: const Text('Use GPS'),
              visualDensity: VisualDensity.compact,
              onPressed: () =>
                  ref.read(locationControllerProvider.notifier).refresh(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude (N+)',
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _lonController,
                decoration: const InputDecoration(
                  labelText: 'Longitude (E+)',
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: _applyManual,
              child: const Text('Set'),
            ),
          ],
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
