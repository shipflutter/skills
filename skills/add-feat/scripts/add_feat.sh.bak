#!/bin/bash
set -e

command="${1:-help}"
feature_slug="${2:-}"
epic_id="${3:-EP01}"

usage() {
  cat <<'EOF'
Usage:
  add_feat.sh gen-tdd <feature-slug> [EPXX]

Examples:
  add_feat.sh gen-tdd auth EP01
  add_feat.sh gen-tdd sign-in EP02

Behavior:
  Scans lib/presentation/<feature-slug> when present.
  Creates resources/user-story/epXX-<feature-slug>.md.
  Creates resources/technial-design/epXX-<feature-slug>.md.
  Requires unit, widget, integration, driver/screenshot tests, and e2e-index.html report generation.
EOF
}

titleize() {
  printf '%s' "$1" | sed 's/[-_]/ /g' | awk '{ for (i=1;i<=NF;i++) { $i=toupper(substr($i,1,1)) substr($i,2) } print }'
}

require_feature() {
  if [ -z "$feature_slug" ]; then
    usage >&2
    exit 1
  fi
}

scan_feature_files() {
  local presentation_dir="lib/presentation/$feature_slug"
  if [ -d "$presentation_dir" ]; then
    find "$presentation_dir" -type f -name '*.dart' | sort
  fi
}

gen_tdd() {
  require_feature

  local epic_lower
  epic_lower="$(printf '%s' "$epic_id" | tr '[:upper:]' '[:lower:]')"
  local feature_title
  feature_title="$(titleize "$feature_slug")"
  local user_story_path="resources/user-story/${epic_lower}-${feature_slug}.md"
  local tech_path="resources/technial-design/${epic_lower}-${feature_slug}.md"
  local files
  files="$(scan_feature_files || true)"

  mkdir -p resources/user-story resources/technial-design

  cat > "$user_story_path" <<EOF
# ${epic_id}: ${feature_title} User Stories

## ${epic_id}.US001: Open ${feature_title}
As a user, I want to open the ${feature_title} feature so that I can complete the main workflow.

Acceptance criteria:
- User can reach the ${feature_title} UI from the intended entry point.
- The first screen renders without layout overflow.
- Loading, success, and error states are visible when relevant.

## ${epic_id}.US002: Submit ${feature_title} data
As a user, I want to submit valid ${feature_title} data so that the app can process my request.

Acceptance criteria:
- Required fields are validated.
- Submit dispatches the feature bloc/event or controller action.
- The feature calls the usecase/service layer, not a direct UI API call.
- Success state is rendered.
- Failure state shows a clear message.

## ${epic_id}.US003: Preview ${feature_title} with e2e screenshots
As a developer, I want screenshot e2e coverage for ${feature_title} so that the feature can be visually reviewed.

Acceptance criteria:
- Unit tests exist in \`test/\` for service/usecase behavior.
- Widget tests exist in \`test/\` for rendering and validation.
- Integration tests exist in \`integration_test/\` for the main user flow.
- Driver or screenshot tests exist and save PNG files to \`screenshots/\`.
- \`e2e.sh\` generates \`e2e-index.html\` with screenshot grid and auto-opens it.
- Screenshot items in the HTML report use width equal to screen width divided by 6.
- Screenshot names are stable and include the epic or user-story id.
- The flow appears in SRS traceability.
EOF

  cat > "$tech_path" <<EOF
# ${epic_id} Technical Design: ${feature_title}

## Technologies
- Flutter Material UI.
- Feature UI under \`lib/presentation/${feature_slug}\`.
- BLoC/controller state management when needed.
- Usecase layer for business logic.
- Integration service for API/platform calls.
- Unit, widget, integration, and screenshot e2e tests.

## Entry Points
EOF

  if [ -n "$files" ]; then
    while IFS= read -r file; do
      printf -- "- \`%s\`\n" "$file" >> "$tech_path"
    done <<EOF
$files
EOF
  else
    cat >> "$tech_path" <<EOF
- \`lib/presentation/${feature_slug}/\` (create when implementing)
EOF
  fi

  cat >> "$tech_path" <<EOF

## Flow
1. User opens ${feature_title}.
2. UI renders initial state.
3. User enters data and submits.
4. UI dispatches feature event/action.
5. Usecase validates and calls repository/service.
6. Integration service calls API/platform boundary when needed.
7. UI renders success or error state.

## Flow Diagram
\`\`\`mermaid
flowchart TD
  A[Open ${feature_title}] --> B[Render initial UI]
  B --> C[User enters data]
  C --> D[Submit action]
  D --> E[Bloc or controller]
  E --> F[Usecase]
  F --> G{Needs API/service?}
  G -->|Yes| H[Integration service]
  G -->|No| I[Local result]
  H --> J{Result}
  I --> J
  J -->|Success| K[Render success]
  J -->|Failure| L[Render error]
\`\`\`

## Entities
| Entity | Purpose | Fields |
|---|---|---|
| ${feature_title}Request | User-submitted input | Add fields during implementation |
| ${feature_title}Result | Service/usecase output | Add fields during implementation |
| ${feature_title}State | UI state | initial, loading, success, error |

## Tests
- Unit tests in \`test/\` for usecase/service behavior.
- Widget tests in \`test/\` for form rendering and validation.
- Integration tests in \`integration_test/\` for the main user flow.
- Driver tests in \`test_driver/\` when using \`flutter drive\`.
- Screenshot tests save PNG files to \`screenshots/\`.
- \`e2e.sh\` runs the test suite, captures screenshots, generates \`e2e-index.html\`, and auto-opens the report.
- Screenshot items in \`e2e-index.html\` use width equal to screen width divided by 6.

## Verification
\`\`\`bash
flutter test
./e2e.sh
./resources/srs.sh
\`\`\`
EOF

  echo "Wrote $user_story_path"
  echo "Wrote $tech_path"
}

case "$command" in
  gen-tdd)
    gen_tdd
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

