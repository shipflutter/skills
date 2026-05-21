import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
      onScreenshot: (String name, List<int> bytes,
          [Map<String, Object?>? args]) async {
        final screenshotsDir = Directory('screenshots');
        if (!screenshotsDir.existsSync()) {
          screenshotsDir.createSync(recursive: true);
        }

        final file = File('${screenshotsDir.path}/$name.png');
        await file.writeAsBytes(bytes, flush: true);
        return true;
      },
    );
