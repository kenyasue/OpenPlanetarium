import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/location/location_controller.dart';
import '../../../../application/location/world_cities_provider.dart';
import '../../../../domain/models/geo_location.dart';
import '../../../../domain/models/land_ring.dart';
import '../../../../domain/models/world_city.dart';
import '../../../../domain/models/world_map_projection.dart';
import '../../../painters/world_map_painter.dart';
import '../../../widgets/search_picker.dart';

/// Observing location section: country/city pickers, a zoomable world map
/// (tap to set the location), manual lat/lon entry, and GPS refresh.
class LocationSection extends ConsumerStatefulWidget {
  const LocationSection({super.key});

  @override
  ConsumerState<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends ConsumerState<LocationSection> {
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _transformation = TransformationController();

  /// Country/city picker state. Kept as widget state (not app state): the
  /// selection is only an input aid; the authoritative location lives in
  /// [locationControllerProvider].
  String? _selectedCountry;
  WorldCity? _selectedCity;

  /// Rebuilds city dots at constant screen size after a zoom gesture.
  /// Updated only on interaction end: repainting the whole map every frame
  /// during a pinch caused visible jank on mobile.
  double _viewScale = 1.0;

  /// Land silhouette path cache (normalized coordinates), rebuilt only when
  /// the ring data instance changes
  Path? _landPath;
  List<LandRing>? _landPathSource;

  /// A map tap within this distance of a city also selects it in the pickers
  static const _citySnapDistanceKm = 150.0;

  /// Input error (shown inline so it works inside dialogs too;
  /// ScaffoldMessenger cannot be safely referenced from a dialog context)
  String? _errorText;

  /// Whether the lat/lon fields were seeded from the current fix (once per
  /// mount; afterwards ref.listen keeps them in sync)
  bool _fieldsSeeded = false;

  /// Reflects [location] into the lat/lon input fields so every selection
  /// route (city picker, map tap, GPS, restored setting) shows its
  /// coordinates ready for manual fine-tuning.
  void _syncFields(GeoLocation location) {
    _latController.text = location.latitudeDeg.toStringAsFixed(4);
    _lonController.text = location.longitudeDeg.toStringAsFixed(4);
  }

  @override
  void dispose() {
    _transformation.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _onMapInteractionEnd() {
    final scale = _transformation.value.getMaxScaleOnAxis();
    if ((scale - _viewScale).abs() > 0.01) {
      setState(() => _viewScale = scale);
    }
  }

  void _setLocation(GeoLocation location) {
    ref.read(locationControllerProvider.notifier).setManualLocation(location);
  }

  void _selectCity(WorldCity city) {
    setState(() {
      _selectedCountry = city.country;
      _selectedCity = city;
    });
    _setLocation(city.toGeoLocation());
  }

  /// Map tap: set the exact tapped coordinates, and snap the pickers to the
  /// nearest city when one is close enough.
  void _onMapTap(Offset scenePosition, Size mapSize) {
    final x = scenePosition.dx / mapSize.width;
    final y = scenePosition.dy / mapSize.height;
    if (!isOnMap(x, y)) return;
    final lat = mapYToLat(y);
    final lon = mapXToLon(x);

    final catalog = ref.read(worldCityCatalogProvider).value;
    final nearest = catalog == null
        ? null
        : nearestCity(catalog.cities, lat, lon);
    final snapped =
        nearest != null && nearest.distanceKm <= _citySnapDistanceKm;
    setState(() {
      _selectedCountry = snapped ? nearest.city.country : null;
      _selectedCity = snapped ? nearest.city : null;
    });
    _setLocation(
      GeoLocation(
        latitudeDeg: double.parse(lat.toStringAsFixed(4)),
        longitudeDeg: double.parse(lon.toStringAsFixed(4)),
        name: snapped ? nearest.city.name : 'Map point',
      ),
    );
  }

  void _applyManual() {
    final lat = double.tryParse(_latController.text);
    final lon = double.tryParse(_lonController.text);
    if (lat == null || lat < -90 || lat > 90) {
      setState(
        () => _errorText = 'Latitude must be a number between -90 and 90',
      );
      return;
    }
    if (lon == null || lon < -180 || lon > 180) {
      setState(
        () => _errorText = 'Longitude must be a number between -180 and 180',
      );
      return;
    }
    setState(() {
      _errorText = null;
      _selectedCountry = null;
      _selectedCity = null;
    });
    _setLocation(
      GeoLocation(latitudeDeg: lat, longitudeDeg: lon, name: 'Manual'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fix = ref.watch(locationControllerProvider).value;
    final catalogAsync = ref.watch(worldCityCatalogProvider);

    // Keep the lat/lon fields following the authoritative location: seed
    // them from the restored/current fix on first build, then track every
    // change (city selection, map tap, GPS result)
    ref.listen(locationControllerProvider, (previous, next) {
      final location = next.value?.location;
      if (location != null) _syncFields(location);
    });
    if (!_fieldsSeeded && fix != null) {
      _fieldsSeeded = true;
      _syncFields(fix.location);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Observing Location', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        switch (catalogAsync) {
          AsyncData(:final value) => _buildPickers(value),
          AsyncError() => Text(
            'City catalog unavailable',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          _ => const Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        },
        const SizedBox(height: 8),
        _buildMap(fix),
        const SizedBox(height: 4),
        Text(
          'Tap the map to set the observing location (scroll/pinch to zoom).',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
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
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.my_location, size: 14),
              label: const Text('GPS'),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  _selectedCountry = null;
                  _selectedCity = null;
                });
                ref.read(locationControllerProvider.notifier).refresh();
              },
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

  static const _allCountriesLabel = 'All countries';

  Future<void> _pickCountry(WorldCityCatalog catalog) async {
    final selected = await showSearchPickerDialog<String>(
      context,
      title: 'Country',
      items: [_allCountriesLabel, ...catalog.countries],
      labelOf: (country) => country,
    );
    if (selected == null) return; // dismissed
    setState(() {
      _selectedCountry = selected == _allCountriesLabel ? null : selected;
      // Keep the city only if it belongs to the new country
      if (_selectedCountry != null &&
          _selectedCity?.country != _selectedCountry) {
        _selectedCity = null;
      }
    });
  }

  Future<void> _pickCity(WorldCityCatalog catalog) async {
    // Without a country every city is offered, labeled with its country to
    // disambiguate duplicates (e.g. San José)
    final country = _selectedCountry;
    final selected = await showSearchPickerDialog<WorldCity>(
      context,
      title: 'City',
      items: country == null ? catalog.cities : catalog.citiesOf(country),
      labelOf: (city) =>
          country == null ? '${city.name} (${city.country})' : city.name,
    );
    if (selected != null) _selectCity(selected);
  }

  Widget _buildPickers(WorldCityCatalog catalog) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Side by side when the host is wide enough (settings dialog),
        // stacked on narrow screens (mobile settings page)
        final fieldWidth = constraints.maxWidth >= 500
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: fieldWidth,
              child: PickerField(
                key: const ValueKey('country-picker'),
                label: 'Country',
                value: _selectedCountry ?? _allCountriesLabel,
                onTap: () => _pickCountry(catalog),
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: PickerField(
                key: const ValueKey('city-picker'),
                label: 'City',
                value: _selectedCity?.name ?? '—',
                onTap: () => _pickCity(catalog),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMap(LocationFix? fix) {
    final landAsync = ref.watch(worldLandRingsProvider);
    final catalog = ref.watch(worldCityCatalogProvider).value;
    final marker = fix?.location;

    return AspectRatio(
      // Equirectangular world map is exactly 2:1 (360° × 180°)
      aspectRatio: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: switch (landAsync) {
          AsyncData(:final value) => LayoutBuilder(
            builder: (context, constraints) {
              final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
              // Build the land path once per catalog instance (identity
              // check: the provider caches the ring list)
              if (_landPathSource != value) {
                _landPathSource = value;
                _landPath = buildLandPath(value);
              }
              return InteractiveViewer(
                transformationController: _transformation,
                maxScale: 8,
                onInteractionEnd: (_) => _onMapInteractionEnd(),
                child: GestureDetector(
                  // Inside the InteractiveViewer the child's local
                  // coordinates are scene coordinates, so no inverse
                  // transform is needed
                  onTapUp: (details) =>
                      _onMapTap(details.localPosition, mapSize),
                  child: CustomPaint(
                    size: mapSize,
                    isComplex: true,
                    willChange: false,
                    painter: WorldMapPainter(
                      landPath: _landPath!,
                      cities: catalog?.cities ?? const [],
                      marker: marker,
                      viewScale: _viewScale,
                    ),
                  ),
                ),
              );
            },
          ),
          AsyncError() => const ColoredBox(
            color: Color(0xFF0D1B2A),
            child: Center(
              child: Text(
                'World map unavailable',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          _ => const ColoredBox(
            color: Color(0xFF0D1B2A),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        },
      ),
    );
  }
}
