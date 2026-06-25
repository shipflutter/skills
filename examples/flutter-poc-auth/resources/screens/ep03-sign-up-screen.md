# Sign-up Screen Layout

## Layout Mode: Single-column

```
┌──────────────────────────────────────────────┐
│  AppBar: "Create account"            [back]  │
├──────────────────────────────────────────────┤
│                                              │
│  Create your account                         │
│  Sign up to start using the POC.             │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [user] Display name                    │  │
│  │ [Your name...                     ]    │  │
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
│  ┌────────────────────────────────────────┐  │
│  │          [Create account]              │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  Already have an account? [Sign in]          │
│                                              │
└──────────────────────────────────────────────┘
```

## Components
- App bar: `Create account` with a back action
- Display name field: TextField for the user's name
- Email field: TextField with email keyboard
- Password field: TextField with obscured text
- Submit button: FilledButton labelled `Create account`
- Sign in link: TextButton -> back to sign-in screen

## States
- Initial: Empty form with the submit button disabled until valid
- Loading: Button shows `Creating...` and is disabled
- Success: Shows the created account summary
- Error: Shows a clear validation error message

## Events
- SignUpRequested -> call AuthService.signUp()
- BackToSignInTapped -> switch back to sign-in screen
