#!/usr/bin/env bash
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
    :root { color-scheme: light dark; --bg: #ffffff; --card: #ffffff; --text: #111827; --muted: #374151; --border: #e5e7eb; --pass: #15803d; }
    [data-theme="dark"] { --bg: #0f172a; --card: #111827; --text: #e5e7eb; --muted: #cbd5e1; --border: #334155; --pass: #86efac; }
    body { font-family: system-ui, sans-serif; margin: 24px; color: var(--text); background: var(--bg); }
    header { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 20px; }
    button { border: 1px solid var(--border); border-radius: 999px; padding: 8px 12px; color: var(--text); background: var(--card); cursor: pointer; }
    h1, h2 { margin-bottom: 12px; }
    .card { background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 16px; margin-bottom: 20px; box-shadow: 0 1px 2px rgba(0,0,0,.04); }
    .summary { font-size: 18px; }
    ul { margin: 0; padding-left: 20px; }
    li { margin: 6px 0; }
    .grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 16px; }
    @media (max-width: 1920px) { .grid { grid-template-columns: repeat(4, 1fr); } }
    @media (max-width: 1200px) { .grid { grid-template-columns: repeat(3, 1fr); } }
    @media (max-width: 768px) { .grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 480px) { .grid { grid-template-columns: 1fr; } }
    figure { margin: 0; }
    img { width: 100%; height: auto; max-width: calc(100vw / 6 - 32px); border: 1px solid var(--border); border-radius: 10px; background: #fff; }
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

DEVICE_ID="${1:-}"
DEVICE_ARGS=()
if [[ -n "$DEVICE_ID" ]]; then
  DEVICE_ARGS=(-d "$DEVICE_ID")
fi

flutter pub get

run_flutter_step "Flutter unit tests" flutter test
run_flutter_step "screenshot_test.dart" flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart \
  "${DEVICE_ARGS[@]}"

build_report
open_report

echo "Wrote $REPORT_FILE"
