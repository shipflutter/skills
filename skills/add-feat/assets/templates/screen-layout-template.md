# Screen Layout Template (ASCII Layout Document)

Use ASCII-style art with box-drawing characters to define screen layouts for AI agents. This document type is an ASCII layout document: a token-efficient, text-native wireframe that preserves screen structure without screenshots or verbose prose.

SRS export expects files in `resources/screens/epXX-<feature>-screen.md` and renders them into the `Screens / UI Surfaces` section of `srs-index.html`.

## Format

```
# [Screen Name]

## Layout Mode: [Single-column | Split-panel | Tab-based | Grid]

[ASCII wireframe using ┌─┐│└┘├┤┬┴]

## Components
- Component A: [description]
- Component B: [description]

## States (optional)
- Initial: [default visible state]
- Loading: [busy state]
- Success: [successful completion state]
- Error: [validation or service failure state]

## Events (optional)
- Event X → Action
```

## ASCII Layout Characters
- Corners: `┌` `┐` `└` `┘`
- Lines: `─` `│`
- Junctions: `├` `┤` `┬` `┴` `┼`

## Conventions
- Use `[icon_name]` for icons
- Use `[Button Text]` for buttons
- Use `[Input placeholder...]` for text fields
- Use `...` for scrollable/expandable content
- Add flex ratios or constraints as comments below wireframe

## Example: Sign In Screen

```
# Sign In Screen

## Layout Mode: Single-column

┌──────────────────────────────────────────────┐
│  AppBar: "Sign In"                    [close] │
├──────────────────────────────────────────────┤
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [mail] Email                           │  │
│  │ [Enter your email...              ]    │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [lock] Password                        │  │
│  │ [Enter password...                ] [eye] │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  [Forgot password?]                          │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │         [Sign In]                      │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  Don't have an account? [Sign up]           │
│                                              │
└──────────────────────────────────────────────┘

## Components
- Email field: TextField with email validation
- Password field: TextField with obscureText, toggle visibility icon
- Forgot password link: TextButton → navigate to ForgotPasswordScreen
- Sign in button: FilledButton, disabled when loading
- Sign up link: TextButton → navigate to SignUpScreen

## Events
- SignInRequested → validate fields, call AuthService.signIn()
- ForgotPasswordTapped → navigate to /forgot-password
- SignUpTapped → navigate to /sign-up
```

## Benefits
- **Token-efficient:** ASCII art is lighter than prose descriptions
- **Visual:** Agent "sees" structure immediately
- **Standardized:** Easy to train agents on `┌─┐` patterns
- **Flexible:** Can add flex ratios, padding hints inline

## SRS Export
- Store screen layout files under `resources/screens/`.
- Keep the first heading as the screen name; `resources/srs.sh` uses it as the generated subsection title.
- Keep the wireframe in a fenced code block so HTML export preserves spacing and box-drawing characters.
