# EP03: Sign Up User Stories

## EP03.US001: Dedicated sign-up screen
Status: Backlog
As a new user, I want a dedicated sign-up screen so that I can create an account without switching modes on the sign-in screen.

Acceptance criteria:
- A standalone sign-up screen is reachable from the sign-in screen.
- The screen collects display name, email, and password.
- Submitting calls `AuthService.signUp()` and shows the account summary.
- Invalid input shows a clear validation error.
- A "Sign in" link returns to the sign-in screen.
- The sign-up screen layout is documented in `resources/screens/ep03-sign-up-screen.md`.
