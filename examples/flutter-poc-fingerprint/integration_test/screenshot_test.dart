import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_poc_fingerprint/main.dart' as app;

import 'helpers/screenshot_helper.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  testWidgets('saves fingerprint report screenshot', (tester) async {
    await prepareScreenshotSurface(tester);
    app.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final errorFinder = find.textContaining('Could not load device info');
    expect(errorFinder, findsNothing);
    expect(find.text('Privacy-safe local report'), findsOneWidget);
    expect(find.text('Fingerprint'), findsOneWidget);

    await saveScreenshot(binding, tester, 'fingerprint_report');
  });
}
