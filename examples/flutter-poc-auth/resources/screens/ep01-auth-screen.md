# Auth Sign-in and Sign-up Screen Layout

## Layout Mode: Single-column

```
┌──────────────────────────────────────────────┐
│  AppBar: "Flutter POC Auth"                  │
├──────────────────────────────────────────────┤
│                                              │
│  Auth Demo                                   │
│  Local deterministic sign-in/sign-up POC     │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [Sign in] [Sign up]                    │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [mail] Email                           │  │
│  │ [demo@shipflutter.dev             ]    │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [lock] Password                        │  │
│  │ [password123                      ]    │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  [Forgot password?]                          │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │          [Sign in]                     │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  Success/error result area                  │
│                                              │
└──────────────────────────────────────────────┘
```

## Components
- App bar: `Flutter POC Auth`
- Mode selector: `SegmentedButton<AuthMode>` with Sign in and Sign up options
- Email field: TextField with email keyboard
- Password field: TextField with obscured text
- Display name field: TextField shown only in sign-up mode
- Forgot password link: TextButton shown only in sign-in mode
- Submit button: FilledButton with sign-in/sign-up label
- Result area: Text summary for success or error message

## States
- Initial: Sign-in mode with demo email and password prefilled
- Sign-up: Display name field appears and submit label changes to `Create account`
- Loading: Submit button is disabled and label changes to `Submitting...`
- Success: Shows returned user id, email, and optional display name
- Error: Shows service validation error in red

## Events
- AuthModeChanged -> switch between sign-in and sign-up modes
- SignInRequested -> call AuthService.signIn()
- SignUpRequested -> call AuthService.signUp()
- ForgotPasswordTapped -> switch to forgot password mode
