---
name: flutter-driver-screenshot-test
description: Add Flutter driver based integration tests that capture screenshots, generate an e2e-index.html report, show passed test counts, and auto-open the report. Use when adding e2e screenshot tests with flutter drive.
---

# Flutter Driver Screenshot Test Skill

Use this skill when an AI agent needs to add Flutter end-to-end tests that save screenshot PNG files during `flutter drive` runs and produce a browsable HTML report.

## Goal

Run Flutter integration tests through a driver process, persist screenshots on the host machine, generate `e2e-index.html`, show how many test cases passed from the Flutter test summary, and open the report automatically when the run finishes.

## Required dependencies

Add these dev dependencies when missing:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

## Directory layout

```text
integration_test/
  helpers/
    screenshot_helper.dart
  screenshot_test.dart
test_driver/
  integration_test.dart
e2e.sh
e2e-index.html
screenshots/
```

## Screenshot helper

Use this pattern inside `integration_test/helpers/screenshot_helper.dart`:

```dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const screenshotSurfaceSize = Size(390, 844);

Future<void> prepareScreenshotSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(screenshotSurfaceSize);
}

Future<void> saveScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 100));

  var platformName = 'web';
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      platformName = 'android';
    } else if (Platform.isIOS) {
      platformName = 'ios';
    } else {
      platformName = Platform.operatingSystem;
    }
  }

  await binding.takeScreenshot('$name-$platformName');
}
```

The helper must not create directories or write files. The app process may run on a read-only filesystem.

## Driver that saves PNG files

Use this pattern inside `test_driver/integration_test.dart`:

```dart
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
```

## Test pattern

```dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  testWidgets('saves home screen screenshot', (tester) async {
    await prepareScreenshotSurface(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await saveScreenshot(binding, tester, 'home_screen');
  });
}
```

## Run command and HTML report

Use `e2e.sh` from this skill. Add one `run_flutter_step` call per target file.

The script must:

- write every step output to a log file;
- parse Flutter summaries like `flutter: 00:07 +11: All tests passed!` or `All tests passed.`;
- show the total passed test count in `e2e-index.html`;
- render all `screenshots/*.png` in the report;
- include light/dark theme handling with a browser-friendly theme toggle;
- auto-open `e2e-index.html` after the run finishes.

Use this pattern for `e2e.sh`:

```bash
#!/bin/bash
set -euo pipefail

REPORT_FILE="e2e-index.html"
LOG_FILE="e2e.log"
PASSED_TESTS=()
TOTAL_PASSED=0

: > "$LOG_FILE"

run_flutter_step() {
  local label="$1"
  shift

  echo "=== $label ===" | tee -a "$LOG_FILE"
  "$@" 2>&1 | tee -a "$LOG_FILE"
  PASSED_TESTS+=("$label")
}

extract_total_passed() {
  local count
  count=$(grep -Eo '\+[0-9]+: All tests passed!?' "$LOG_FILE" | tail -1 | grep -Eo '[0-9]+' || true)
  if [ -n "$count" ]; then
    TOTAL_PASSED="$count"
  else
    TOTAL_PASSED="${#PASSED_TESTS[@]}"
  fi
}

build_report() {
  mkdir -p screenshots
  extract_total_passed

  cat > "$REPORT_FILE" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>E2E Report</title>
  <style>
    :root { color-scheme: light dark; --bg: #f9fafb; --card: #ffffff; --text: #111827; --muted: #374151; --border: #e5e7eb; --pass: #15803d; }
    [data-theme="dark"] { --bg: #0f172a; --card: #111827; --text: #e5e7eb; --muted: #cbd5e1; --border: #334155; --pass: #86efac; }
    body { font-family: system-ui, sans-serif; margin: 24px; color: var(--text); background: var(--bg); }
    header { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 20px; }
    button { border: 1px solid var(--border); border-radius: 999px; padding: 8px 12px; color: var(--text); background: var(--card); cursor: pointer; }
    h1, h2 { margin-bottom: 12px; }
    .card { background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 16px; margin-bottom: 20px; box-shadow: 0 1px 2px rgba(0,0,0,.04); }
    .summary { font-size: 18px; }
    ul { margin: 0; padding-left: 20px; }
    li { margin: 6px 0; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px; }
    figure { margin: 0; }
    img { width: 100%; height: auto; border: 1px solid var(--border); border-radius: 10px; background: #fff; }
    figcaption { margin-top: 8px; font-size: 14px; color: var(--muted); word-break: break-word; }
    .pass { color: var(--pass); font-weight: 600; }
  </style>
</head>
<body>
  <header>
    <h1>E2E Report</h1>
    <button type="button" onclick="toggleTheme()">Toggle theme</button>
  </header>
  <div class="card summary"><span class="pass">$TOTAL_PASSED</span> test cases passed</div>
  <div class="card">
    <h2>Passed test runs</h2>
    <ul>
EOF

  for test_case in "${PASSED_TESTS[@]}"; do
    printf '      <li class="pass">%s</li>\n' "$test_case" >> "$REPORT_FILE"
  done

  cat >> "$REPORT_FILE" <<'EOF'
    </ul>
  </div>
  <div class="card">
    <h2>Screenshots</h2>
    <div class="grid">
EOF

  if ls screenshots/*.png >/dev/null 2>&1; then
    for screenshot in screenshots/*.png; do
      name=$(basename "$screenshot")
      printf '      <figure><img src="screenshots/%s" alt="%s" /><figcaption>%s</figcaption></figure>\n' "$name" "$name" "$name" >> "$REPORT_FILE"
    done
  else
    cat >> "$REPORT_FILE" <<'EOF'
      <p>No screenshots found.</p>
EOF
  fi

  cat >> "$REPORT_FILE" <<'EOF'
    </div>
  </div>
  <script>
    const savedTheme = localStorage.getItem('e2e-theme');
    const preferredTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    document.documentElement.dataset.theme = savedTheme || preferredTheme;
    function toggleTheme() {
      const next = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
      document.documentElement.dataset.theme = next;
      localStorage.setItem('e2e-theme', next);
    }
  </script>
</body>
</html>
EOF
}

open_report() {
  if command -v open >/dev/null 2>&1; then
    open "$REPORT_FILE"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$REPORT_FILE"
  fi
}

flutter pub get

run_flutter_step "Flutter unit tests" flutter test
run_flutter_step "integration_test/screenshot_test.dart" flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart

build_report
open_report

echo "Wrote $REPORT_FILE"
```

## Rules

- Save screenshots from the driver process only.
- Import `integration_test_driver_extended.dart` when using `onScreenshot`.
- Do not write screenshots from files under `integration_test/`.
- Keep screenshot names stable and platform-suffixed.
- Generate `e2e-index.html` after all test steps pass.
- Parse the passed test count from Flutter output such as `flutter: 00:07 +11: All tests passed!` and display it in the report.
- If no `+N` summary is found, fall back to the number of passed script steps.
- Include light/dark theme support and a manual theme toggle in the report.
- Auto-open the report after generation with `open` on macOS or `xdg-open` on Linux.
- Run with a booted emulator or simulator visible in `flutter devices`.
