import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poc_fingerprint/main.dart';

void main() {
  testWidgets('renders device fingerprint POC shell', (tester) async {
    await tester.pumpWidget(const FingerprintPocApp());

    expect(find.text('Device fingerprint POC'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.textContaining('Could not load device info'), findsNothing);
    expect(find.text('Privacy-safe local report'), findsOneWidget);
  });
}
