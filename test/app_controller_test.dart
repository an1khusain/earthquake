import 'package:earthquake/controllers/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

void main() {
  late List<Uri> requests;

  AppController createController(http.Response Function() respond) {
    requests = [];
    return AppController(
      client: MockClient((request) async {
        requests.add(request.url);
        return respond();
      }),
    );
  }

  setUp(() => Get.testMode = true);

  test('builds ISO-8601 query without location by default', () async {
    final c = createController(() => http.Response(sampleGeoJson, 200));
    c.onInit();
    await Future<void>.delayed(Duration.zero);

    final params = requests.single.queryParameters;
    expect(params['format'], 'geojson');
    expect(
      params['starttime'],
      matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$')),
    );
    expect(
      params['endtime'],
      matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$')),
    );
    expect(params['minmagnitude'], '4.0');
    expect(params['orderby'], 'time');
    expect(params['limit'], '50');
    expect(params.containsKey('latitude'), isFalse);
    expect(params.containsKey('maxradiuskm'), isFalse);
  });

  test('loads earthquakes on success', () async {
    final c = createController(() => http.Response(sampleGeoJson, 200));
    c.onInit();
    await Future<void>.delayed(Duration.zero);

    expect(c.isLoading, isFalse);
    expect(c.errorMessage, isNull);
    expect(c.earthquakes, hasLength(2));
  });

  test('exposes server errors', () async {
    final c = createController(
      () => http.Response('Bad Request: starttime is invalid\nmore', 400),
    );
    c.onInit();
    await Future<void>.delayed(Duration.zero);

    expect(c.hasDataLoaded, isFalse);
    expect(
      c.errorMessage,
      'USGS returned 400: Bad Request: starttime is invalid',
    );
  });

  test('filters refetch only after a change', () async {
    final c = createController(() => http.Response(sampleGeoJson, 200));
    c.onInit();
    await Future<void>.delayed(Duration.zero);
    expect(requests, hasLength(1));

    await c.refreshIfFiltersChanged();
    expect(requests, hasLength(1));

    c.setMagnitude(5.5);
    await c.refreshIfFiltersChanged();
    expect(requests, hasLength(2));
    expect(requests.last.queryParameters['minmagnitude'], '5.5');
  });

  test('keeps start date before end date', () {
    final c = createController(() => http.Response(sampleGeoJson, 200));
    c.onInit();

    c.setEndDate(DateTime(2024, 1, 10));
    c.setStartDate(DateTime(2024, 2, 1));
    expect(c.endDate, DateTime(2024, 2, 1));

    c.setEndDate(DateTime(2023, 12, 1));
    expect(c.startDate, DateTime(2023, 12, 1));
  });

  test('failed refresh keeps filters of the displayed results', () async {
    var fail = false;
    final c = createController(
      () =>
          fail
              ? http.Response('Service unavailable', 503)
              : http.Response(sampleGeoJson, 200),
    );
    c.onInit();
    await Future<void>.delayed(Duration.zero);
    expect(c.appliedFilters?.orderBy, 'time');

    fail = true;
    c.setOrder('magnitude');
    await Future<void>.delayed(Duration.zero);

    expect(c.orderBy, 'magnitude');
    expect(c.appliedFilters?.orderBy, 'time');
    expect(c.earthquakes, hasLength(2));
    expect(c.errorMessage, startsWith('USGS returned 503'));
  });
}
