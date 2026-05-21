import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_poc_fingerprint/src/models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('creates a deterministic SHA-256 device fingerprint',
      (tester) async {
    final fingerprint = buildFingerprint(
      buildFingerprintInput(const {
        'locale': 'en-VN',
        'timezoneOffsetMinutes': 420,
        'devicePixelRatio': 3,
        'colorScheme': 'light',
      }),
    );

    expect(fingerprint, hasLength(64));
    expect(fingerprint, matches(RegExp(r'^[a-f0-9]{64}$')));
    expect(
      fingerprint,
      buildFingerprint(
        buildFingerprintInput(const {
          'colorScheme': 'light',
          'devicePixelRatio': 3.0,
          'timezoneOffsetMinutes': 420,
          'locale': 'en-GB',
        }),
      ),
    );
  });
}
