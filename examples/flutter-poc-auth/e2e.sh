#!/usr/bin/env bash
set -euo pipefail

REPORT_FILE="e2e-index.html"
SCREENSHOT_DIR="screenshots"
PASSED_STEPS=()
FAILED_STEPS=()

run_step() {
  local label="$1"
  shift

  echo "Running $label..."
  if "$@"; then
    PASSED_STEPS+=("$label")
  else
    FAILED_STEPS+=("$label")
  fi
}

build_report() {
  mkdir -p "$SCREENSHOT_DIR"

  cat > "$REPORT_FILE" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Flutter POC Auth E2E Report</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 24px; color: #111827; background: #f9fafb; }
    h1, h2 { margin-bottom: 12px; }
    .card { background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 16px; margin-bottom: 20px; box-shadow: 0 1px 2px rgba(0,0,0,.04); }
    ul { margin: 0; padding-left: 20px; }
    li { margin: 6px 0; }
    .grid { display: grid; grid-template-columns: repeat(6, calc((100vw - 48px - 80px) / 6)); gap: 16px; overflow-x: auto; }
    figure { margin: 0; width: calc((100vw - 48px - 80px) / 6); }
    img { width: 100%; height: auto; border: 1px solid #d1d5db; border-radius: 10px; background: #fff; }
    figcaption { margin-top: 8px; font-size: 14px; color: #374151; word-break: break-word; }
    .story { display: block; margin-top: 4px; color: #6b7280; font-size: 12px; }
    .filters { display: flex; flex-wrap: wrap; gap: 8px; margin: 12px 0 16px; }
    .filter-button { border: 1px solid #d1d5db; border-radius: 999px; background: #fff; color: #374151; cursor: pointer; padding: 6px 12px; }
    .filter-button.active { background: #2563eb; border-color: #2563eb; color: #fff; }
    .hidden { display: none; }
    .pass { color: #15803d; font-weight: 600; }
    .fail { color: #dc2626; font-weight: 600; }
    .summary { margin-bottom: 20px; }
    .summary-stats { display: flex; gap: 24px; }
    .stat-number { font-size: 24px; font-weight: 700; }
  </style>
</head>
<body>
  <h1>Flutter POC Auth E2E Report</h1>
HTML

  cat >> "$REPORT_FILE" <<HTML
  <div class="card summary">
    <h2>Test Summary</h2>
    <div class="summary-stats">
      <div class="stat">
        <div class="stat-number" style="color: #15803d;">${#PASSED_STEPS[@]}</div>
        <div>Passed</div>
      </div>
      <div class="stat">
        <div class="stat-number" style="color: #dc2626;">${#FAILED_STEPS[@]}</div>
        <div>Failed</div>
      </div>
    </div>
  </div>
HTML

  if [[ ${#PASSED_STEPS[@]} -gt 0 ]]; then
    cat >> "$REPORT_FILE" <<'HTML'
    <div class="card">
      <h2>Passed Steps</h2>
      <ul>
HTML
    for step in "${PASSED_STEPS[@]}"; do
      printf '        <li class="pass">✓ %s</li>\n' "$step" >> "$REPORT_FILE"
    done
    cat >> "$REPORT_FILE" <<'HTML'
      </ul>
    </div>
HTML
  fi

  if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
    cat >> "$REPORT_FILE" <<'HTML'
    <div class="card">
      <h2>Failed Steps</h2>
      <ul>
HTML
    for step in "${FAILED_STEPS[@]}"; do
      printf '        <li class="fail">✗ %s</li>\n' "$step" >> "$REPORT_FILE"
    done
    cat >> "$REPORT_FILE" <<'HTML'
      </ul>
    </div>
HTML
  fi

  cat >> "$REPORT_FILE" <<'HTML'
  <div class="card">
    <h2>Screenshots</h2>
    <div class="filters" aria-label="Screenshot user-story filters">
      <button class="filter-button active" type="button" data-filter="all">All</button>
      <button class="filter-button" type="button" data-filter="ep01-auth">EP01 Auth</button>
    </div>
    <div class="grid" id="screenshots-grid">
HTML

  if ls "$SCREENSHOT_DIR"/*.png >/dev/null 2>&1; then
    for screenshot in "$SCREENSHOT_DIR"/*.png; do
      name="$(basename "$screenshot")"
      printf '      <figure data-story="ep01-auth"><img src="screenshots/%s" alt="%s" /><figcaption>%s<span class="story">EP01 Auth</span></figcaption></figure>\n' "$name" "$name" "$name" >> "$REPORT_FILE"
    done
  else
    cat >> "$REPORT_FILE" <<'HTML'
      <p>No screenshots found.</p>
HTML
  fi

  cat >> "$REPORT_FILE" <<'HTML'
    </div>
  </div>
  <script>
    document.querySelectorAll('.filter-button').forEach((button) => {
      button.addEventListener('click', () => {
        const filter = button.dataset.filter;
        document.querySelectorAll('.filter-button').forEach((item) => item.classList.remove('active'));
        button.classList.add('active');
        document.querySelectorAll('#screenshots-grid figure').forEach((figure) => {
          figure.classList.toggle('hidden', filter !== 'all' && figure.dataset.story !== filter);
        });
      });
    });
  </script>
</body>
</html>
HTML
}

open_report() {
  if command -v open >/dev/null 2>&1; then
    open "$REPORT_FILE"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$REPORT_FILE" >/dev/null 2>&1 &
  fi
}

run_step "Dart format" dart format --set-exit-if-changed .
run_step "Flutter analyze" flutter analyze
run_step "Flutter unit tests" flutter test
run_step "Auth sign-in and sign-up flow" flutter test test/auth_flow_widget_test.dart
run_step "Auth screenshot capture" flutter test test/auth_screenshot_test.dart

build_report
open_report

echo "Report: $REPORT_FILE"

if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
  exit 1
fi
