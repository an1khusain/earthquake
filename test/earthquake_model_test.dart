import 'dart:convert';

import 'package:earthquake/models/earthquake_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  test('parses a USGS GeoJSON response', () {
    final model = EarthquakeModel.fromJson(jsonDecode(sampleGeoJson));

    expect(model.metadata?.count, 2);
    expect(model.features, hasLength(2));

    final first = model.features!.first;
    expect(first.id, 'us7000abcd');
    expect(first.properties?.mag, 6.4);
    expect(first.properties?.alert, 'yellow');
    expect(first.properties?.felt, 120);
    expect(first.properties?.tsunami, 1);
    expect(first.geometry?.coordinates, [139.2, 34.7, 35.5]);

    final second = model.features![1].properties!;
    expect(second.alert, isNull);
    expect(second.felt, isNull);
  });
}
