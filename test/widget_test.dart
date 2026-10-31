import 'package:earthquake/controllers/app_controller.dart';
import 'package:earthquake/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('shows earthquakes and opens details', (tester) async {
    Get.put(
      AppController(
        client: MockClient((_) async => http.Response(sampleGeoJson, 200)),
      ),
    );
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('120 km SSW of Tokyo, Japan'), findsOneWidget);
    expect(find.text('50 km N of Anchorage, Alaska'), findsOneWidget);
    expect(find.text('6.4'), findsOneWidget);

    await tester.tap(find.text('120 km SSW of Tokyo, Japan'));
    await tester.pumpAndSettle();

    expect(find.text('Earthquake details'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('35.5 km'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('View on USGS'), 200);
    expect(find.text('View on USGS'), findsOneWidget);
  });
}
