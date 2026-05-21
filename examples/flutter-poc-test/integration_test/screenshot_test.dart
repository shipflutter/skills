import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_poc_test/main.dart';

import 'helpers/screenshot_helper.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  testWidgets('saves score calculator screenshot', (tester) async {
    await prepareScreenshotSurface(tester);
    await tester.pumpWidget(const TestSkillsPocApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Test Skills POC'), findsOneWidget);
    expect(find.text('86.40'), findsOneWidget);

    await saveScreenshot(binding, tester, 'score_calculator_home');
  });
}
