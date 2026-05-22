# Sign In Feature Template

This template shows how to model a feature that calls an API and uses a mocked `service_ft` integration layer.

## User Story Shape

### EPXX.US001: Sign in with email and password
As a user, I want to sign in using my email and password so that I can access the application.

Acceptance criteria:
- User can enter email and password.
- UI validates required fields.
- Submit dispatches bloc event.
- Bloc calls a usecase.
- Usecase calls `service_ft` integration.
- Success navigates to the next screen.
- Failure shows an error state.

## Technical Design Shape

### Flow
1. User enters credentials.
2. UI dispatches `SignInRequested`.
3. Bloc validates and emits loading.
4. Usecase calls `service_ft.signIn()`.
5. Mock `service_ft` returns success or failure in tests.
6. UI renders success or error state.

### Example integration seam
- `service_ft` is the boundary for network/API work.
- Replace `service_ft` with a fake in integration/unit tests.
- Keep API payload mapping in the service layer.

### Suggested files
- `lib/presentation/sign_in/sign_in_screen.dart`
- `lib/presentation/sign_in/bloc/sign_in_bloc.dart`
- `lib/domain/usecases/sign_in_usecase.dart`
- `lib/integration/sign_in/service_ft_impl.dart`
- `test/presentation/sign_in/...`
- `integration_test/sign_in_..._test.dart`

