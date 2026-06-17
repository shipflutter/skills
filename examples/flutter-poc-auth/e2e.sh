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

  local passed_count=${#PASSED_STEPS[@]}
  local failed_count=${#FAILED_STEPS[@]}

  cat > "$REPORT_FILE" << 'HTMLEOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Flutter POC Auth E2E Report</title>
  <style>
    :root {
      --color-primary: #FCD535;
      --color-canvas: #ffffff;
      --color-surface: #fafafa;
      --color-ink: #181a20;
      --color-muted: #707a8a;
      --color-hairline: #eaecef;
      --color-link: #2563eb;
      --font-body: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    * { box-sizing: border-box; }
    body { font-family: var(--font-body); color: var(--color-ink); background: var(--color-surface); margin: 0; padding: 0; line-height: 1.6; }
    .layout { display: grid; grid-template-columns: 280px 1fr; min-height: 100vh; }
    aside { position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto; background: var(--color-canvas); border-right: 1px solid var(--color-hairline); padding: 24px 16px; }
    aside h2 { font-size: 14px; text-transform: uppercase; color: var(--color-muted); margin: 0 0 12px; letter-spacing: .03em; border: 0; padding: 0; }
    aside .meta { color: var(--color-muted); font-size: 13px; margin-bottom: 24px; }
    aside nav ol, aside nav ul { list-style: none; padding: 0; margin: 0; }
    aside nav .toc-h2 > a { font-weight: 600; font-size: 13px; color: var(--color-ink); display: block; padding: 6px 10px; border-radius: 6px; text-decoration: none; }
    aside nav .toc-h2 > a:hover { background: var(--color-surface); }
    main { padding: 40px 60px; max-width: 1280px; }
    h1 { font-size: 32px; border-bottom: 2px solid var(--color-ink); padding-bottom: 12px; margin: 0 0 24px; }
    h2 { margin: 0 0 12px; font-size: 20px; }
    .card { background: var(--color-canvas); border: 1px solid var(--color-hairline); border-radius: 8px; padding: 16px; margin-bottom: 20px; box-shadow: 0 1px 2px rgba(0,0,0,.04); }
    ul { margin: 0; padding-left: 20px; }
    li { margin: 6px 0; }
    .grid { display: grid; grid-template-columns: repeat(6, minmax(160px, 1fr)); gap: 16px; }
    figure { margin: 0; }
    img { width: 100%; height: auto; border: 1px solid var(--color-hairline); border-radius: 8px; background: #fff; }
    figcaption { margin-top: 8px; font-size: 14px; color: var(--color-muted); word-break: break-word; }
    .story { display: block; margin-top: 4px; color: var(--color-muted); font-size: 12px; }
    .filters { display: flex; flex-wrap: wrap; gap: 8px; margin: 12px 0 16px; }
    .filter-button { border: 1px solid var(--color-hairline); border-radius: 999px; background: var(--color-canvas); color: var(--color-muted); cursor: pointer; padding: 6px 12px; font-size: 13px; }
    .filter-button.active { background: var(--color-primary); border-color: var(--color-primary); color: var(--color-ink); }
    .hidden { display: none; }
    .pass { color: #15803d; font-weight: 600; }
    .fail { color: #dc2626; font-weight: 600; }
    .summary-stats { display: flex; gap: 24px; }
    .stat-number { font-size: 24px; font-weight: 700; }
    @media (max-width: 900px) {
      .layout { grid-template-columns: 1fr; }
      aside { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--color-hairline); }
      main { padding: 24px; }
      .grid { grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); }
    }
  </style>
</head>
<body>
  <div class="layout">
    <aside>
      <h2>Flutter POC Auth</h2>
      <div class="meta">E2E Report</div>
      <nav aria-label="Report navigation">
        <ol>
          <li class="toc-h2"><a href="srs-index.html">SRS Index</a></li>
          <li class="toc-h2"><a href="#summary">Test Summary</a></li>
          <li class="toc-h2"><a href="#passed-steps">Passed Steps</a></li>
          <li class="toc-h2"><a href="#failed-steps">Failed Steps</a></li>
          <li class="toc-h2"><a href="#screenshots">Screenshots</a></li>
        </ol>
      </nav>
    </aside>
    <main>
      <h1>Flutter POC Auth E2E Report</h1>
      <div class="card" id="summary">
        <h2>Test Summary</h2>
        <div class="summary-stats">
HTMLEOF

  cat >> "$REPORT_FILE" << HTMLEOF
          <div class="stat">
            <div class="stat-number" style="color: #15803d;">$passed_count</div>
            <div>Passed</div>
          </div>
          <div class="stat">
            <div class="stat-number" style="color: #dc2626;">$failed_count</div>
            <div>Failed</div>
          </div>
        </div>
      </div>
HTMLEOF

  if [[ ${#PASSED_STEPS[@]} -gt 0 ]]; then
    cat >> "$REPORT_FILE" << 'HTMLEOF'
      <div class="card" id="passed-steps">
        <h2>Passed Steps</h2>
        <ul>
HTMLEOF
    for step in "${PASSED_STEPS[@]}"; do
      printf '          <li class="pass">✓ %s</li>\n' "$step" >> "$REPORT_FILE"
    done
    cat >> "$REPORT_FILE" << 'HTMLEOF'
        </ul>
      </div>
HTMLEOF
  fi

  if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
    cat >> "$REPORT_FILE" << 'HTMLEOF'
      <div class="card" id="failed-steps">
        <h2>Failed Steps</h2>
        <ul>
HTMLEOF
    for step in "${FAILED_STEPS[@]}"; do
      printf '          <li class="fail">✗ %s</li>\n' "$step" >> "$REPORT_FILE"
    done
    cat >> "$REPORT_FILE" << 'HTMLEOF'
        </ul>
      </div>
HTMLEOF
  fi

  cat >> "$REPORT_FILE" << 'HTMLEOF'
      <div class="card" id="screenshots">
        <h2>Screenshots</h2>
        <div class="filters" aria-label="Screenshot filters">
          <button class="filter-button active" type="button" data-filter="all">All</button>
          <button class="filter-button" type="button" data-filter="ep01-auth">EP01 Auth</button>
          <button class="filter-button" type="button" data-filter="ep02-forgot-password">EP02 Forgot Password</button>
        </div>
        <div class="grid" id="screenshots-grid">
HTMLEOF

  if ls "$SCREENSHOT_DIR"/*.png >/dev/null 2>&1; then
    for screenshot in "$SCREENSHOT_DIR"/*.png; do
      name="$(basename "$screenshot")"
      story="ep01-auth"
      story_label="EP01 Auth"
      if [[ "$name" == ep02-forgot-password-* ]]; then
        story="ep02-forgot-password"
        story_label="EP02 Forgot Password"
      fi
      printf '          <figure data-story="%s"><img src="screenshots/%s" alt="%s" /><figcaption>%s<span class="story">%s</span></figcaption></figure>\n' "$story" "$name" "$name" "$name" "$story_label" >> "$REPORT_FILE"
    done
  else
    cat >> "$REPORT_FILE" << 'HTMLEOF'
          <p>No screenshots found.</p>
HTMLEOF
  fi

  cat >> "$REPORT_FILE" << 'HTMLEOF'
        </div>
      </div>
    </main>
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
HTMLEOF
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
run_step "Forgot password screenshot capture" flutter test test/forgot_password_screenshot_test.dart

build_report
open_report

echo "Report: $REPORT_FILE"

if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
  exit 1
fi
