# EP01: Auth User Stories

## EP01.US001: Open Auth
As a user, I want to open the Auth feature so that I can complete the main workflow.

Acceptance criteria:
- User can reach the Auth UI from the intended entry point.
- The first screen renders without layout overflow.
- Loading, success, and error states are visible when relevant.

## EP01.US002: Submit Auth data
As a user, I want to submit valid Auth data so that the app can process my request.

Acceptance criteria:
- Required fields are validated.
- Submit dispatches the feature bloc/event or controller action.
- The feature calls the usecase/service layer, not a direct UI API call.
- Success state is rendered.
- Failure state shows a clear message.

## EP01.US003: Preview Auth with e2e screenshots
As a developer, I want screenshot e2e coverage for Auth so that the feature can be visually reviewed.

Acceptance criteria:
- Screenshot test exists in `integration_test/`.
- E2E runner exists in `e2e/`.
- Screenshot names are stable.
- The flow appears in SRS traceability.
