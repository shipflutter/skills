# Forgot Password Screen Layout

## Layout Mode: Single-column

```
┌──────────────────────────────────────────────┐
│  AppBar: "Forgot Password"            [back] │
├──────────────────────────────────────────────┤
│                                              │
│  Reset your password                         │
│  Enter your email and we'll send you         │
│  instructions to reset your password.        │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [mail] Email                           │  │
│  │ [Enter your email...              ]    │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │         [Send Reset Link]              │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  Remember your password? [Sign in]           │
│                                              │
└──────────────────────────────────────────────┘
```

## Components
- Title: "Reset your password" (Text, headline style)
- Description: Instructions text (Text, body style, muted color)
- Email field: TextField with email validation
- Send button: FilledButton, disabled when loading or email invalid
- Sign in link: TextButton -> back to sign-in mode

## States
- Initial: Email field prefilled from sign-in form, button enabled when valid
- Loading: Button shows "Sending...", disabled
- Success: Show success message "Reset link sent to {email}"
- Error: Show error message below button

## Events
- ForgotPasswordRequested -> validate email, call AuthService.forgotPassword()
- BackToSignInTapped -> switch to sign-in mode
