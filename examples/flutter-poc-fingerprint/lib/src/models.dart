import 'dart:convert';

import 'package:crypto/crypto.dart';

class DeviceSnapshot {
  const DeviceSnapshot({
    required this.fingerprint,
    required this.fingerprintInput,
    required this.collectedAt,
    required this.source,
    required this.device,
    required this.referral,
  });

  final String fingerprint;
  final Map<String, Object?> fingerprintInput;
  final DateTime collectedAt;
  final String source;
  final Map<String, Object?> device;
  final Map<String, String> referral;

  Map<String, Object?> toJson() {
    return {
      'fingerprint': fingerprint,
      'fingerprintInput': fingerprintInput,
      'fingerprintInputRaw': jsonEncode(fingerprintInput),
      'collectedAt': collectedAt.toUtc().toIso8601String(),
      'source': source,
      'device': device,
      'referral': referral,
      'privacy': const {
        'localOnly': true,
        'thirdPartyIpLookup': false,
        'invasiveFingerprinting': false,
      },
    };
  }

  String prettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

Map<String, Object?> buildFingerprintInput(Map<String, Object?> device) {
  return {
    'namespace': 'shipflutter-device-v1',
    'locale': _languageCode(device['locale']),
    'timezoneOffsetMinutes': device['timezoneOffsetMinutes'],
    'devicePixelRatio': _normalizedRatio(device['devicePixelRatio']),
    'colorScheme': device['colorScheme'],
  };
}

String _languageCode(Object? locale) {
  return locale?.toString().split(RegExp('[-_]')).first.toLowerCase() ?? '';
}

String _normalizedRatio(Object? ratio) {
  final value = ratio is num ? ratio : num.tryParse(ratio?.toString() ?? '');
  return value?.toStringAsFixed(1) ?? '';
}

String buildFingerprint(Map<String, Object?> fingerprintInput) {
  return sha256.convert(utf8.encode(jsonEncode(fingerprintInput))).toString();
}
