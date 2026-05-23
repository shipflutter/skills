# EP02: Forgot Password User Stories

## EP02.US001: Navigate to forgot password
As a user, I want to access the forgot password screen from the sign-in page so that I can reset my password if I've forgotten it.

Acceptance criteria:
- "Forgot password?" link is visible on the sign-in screen.
- Tapping the link navigates to the forgot password screen.
- The forgot password screen renders without layout overflow.
- Back button returns to sign-in screen.
- The forgot password screen layout is documented in `resources/screens/ep02-forgot-password-screen.md`.

## EP02.US002: Submit forgot password request
As a user, I want to submit my email address to receive password reset instructions.

Acceptance criteria:
- Email field validates format before submission.
- Submit button is disabled when email is empty or invalid.
- Submit calls `AuthService.forgotPassword()` through the page controller action.
- Service returns deterministic local success or validation error response.
- Success state shows "Reset link sent to {email}" message.
- Error state shows clear error message.
- Loading state disables button and shows "Sending..." text.
- Unit and widget coverage exists in `test/auth_service_test.dart` and `test/auth_flow_widget_test.dart`.

## EP02.US003: Preview forgot password with e2e screenshots
As a developer, I want screenshot and e2e report coverage for forgot password so that the feature can be visually reviewed and traced in SRS.

Acceptance criteria:
- Screenshot test exists in `test/forgot_password_screenshot_test.dart`.
- Screenshots capture form and success states:
  - `screenshots/ep02-forgot-password-form.png`
  - `screenshots/ep02-forgot-password-success.png`
- E2E runner `e2e.sh` includes forgot password screenshot capture.
- `e2e-index.html` includes an `EP02 Forgot Password` screenshot filter and links back to `srs-index.html`.
- Screenshot names follow convention: `ep02-forgot-password-*.png`.
- The flow, screenshot artifacts, e2e report, and SRS report appear in SRS traceability.
