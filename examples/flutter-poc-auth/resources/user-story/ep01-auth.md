# EP01: Auth User Stories

## EP01.US001: Open Auth
As a user, I want to open the Auth POC so that I can sign in or create an account from one entry point.

Acceptance criteria:
- `AuthPocApp` launches `AuthPage` from `lib/main.dart`.
- The sign-in mode is visible by default with email and password fields.
- The sign-up mode can be selected and reveals the display name field.
- The first screen renders without layout overflow at the screenshot surface size `390x844`.
- The sign-in/sign-up screen layout is documented in `resources/screens/ep01-auth-screen.md`.

## EP01.US002: Submit Auth data
As a user, I want to submit sign-in or sign-up data so that the app can render the returned account summary.

Acceptance criteria:
- Sign-in submits demo credentials through `AuthService.signIn()`.
- Sign-up submits email, password, and display name through `AuthService.signUp()`.
- Loading state disables the submit button while the local service resolves.
- Success state shows `User ID`, `Email`, and display name when available.
- Invalid data from the service renders a clear error message.
- Unit and widget coverage exists in `test/auth_service_test.dart` and `test/auth_flow_widget_test.dart`.

## EP01.US003: Preview Auth with e2e screenshots
As a developer, I want screenshot and e2e report coverage for Auth so that the feature can be visually reviewed and traced in SRS.

Acceptance criteria:
- Screenshot test exists in `test/auth_screenshot_test.dart`.
- Screenshot output is saved to `screenshots/ep01-auth-sign-in-form.png`.
- E2E runner exists at `e2e.sh` and runs format, analysis, unit/widget tests, auth screenshot capture, and forgot password screenshot capture.
- `e2e.sh` generates `e2e-index.html` with passed/failed step counts, screenshot grid, EP01/EP02 filters, and a link to `srs-index.html`.
- Screenshot names are stable and prefixed with `ep01-auth`.
- The auth flow, screenshot artifact, e2e report, and SRS report appear in SRS traceability.
