import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/location/world_cities_provider.dart';
import 'package:open_planetarium/domain/models/world_city.dart';

WorldCity _city(String name, String country, {bool capital = false}) =>
    WorldCity(
      name: name,
      country: country,
      latitudeDeg: 0,
      longitudeDeg: 0,
      isCapital: capital,
    );

void main() {
  group('WorldCityCatalog', () {
    test('countries are distinct and alphabetically sorted', () {
      final catalog = WorldCityCatalog([
        _city('Osaka', 'Japan'),
        _city('Paris', 'France', capital: true),
        _city('Tokyo', 'Japan', capital: true),
      ]);
      expect(catalog.countries, ['France', 'Japan']);
    });

    test('citiesOf groups by country preserving input order', () {
      final catalog = WorldCityCatalog([
        _city('Osaka', 'Japan'),
        _city('Paris', 'France'),
        _city('Tokyo', 'Japan'),
      ]);
      expect(catalog.citiesOf('Japan').map((c) => c.name), ['Osaka', 'Tokyo']);
      expect(catalog.citiesOf('France').map((c) => c.name), ['Paris']);
    });

    test('citiesOf returns an empty list for an unknown country', () {
      final catalog = WorldCityCatalog([_city('Tokyo', 'Japan')]);
      expect(catalog.citiesOf('Atlantis'), isEmpty);
    });

    test('empty catalog yields empty collections', () {
      final catalog = WorldCityCatalog(const []);
      expect(catalog.cities, isEmpty);
      expect(catalog.countries, isEmpty);
    });
  });
}
