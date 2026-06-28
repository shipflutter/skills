---
name: marketing-app-banner
description: Add a native-style "smart app banner" pinned to the top of a website or web app that auto-detects iOS vs Android and links to the right store (App Store / Google Play). Use when a landing site, marketing page, or in-app web hub (SPA/PWA) needs a dismissible-or-persistent "Get the app" install banner with multi-language copy, dark/light theming, and old-WebKit (iOS 12) safe CSS.
---

# Marketing App Banner

A drop-in, dependency-free "Get the app" banner — a fixed bar pinned to the very top of the
page (above the site header), styled like a native iOS/Android smart-app-banner. It sniffs the
user agent and points the CTA at the correct store. Desktop visitors don't see it (an install
prompt is pointless there).

This skill ships two integration paths:
- **Static / multi-page site** → drop in one self-contained JS file (`templates/app-banner.js`).
- **SPA / in-app web hub (PWA, Capacitor webview, etc.)** → see `reference/spa-integration.md`.

## When to use
- A landing/marketing site (static HTML) where you want one banner on every page.
- A web game hub or PWA shell that should nudge mobile-web visitors to install the native app.
- Any page that already has a sticky header you must not overlap.

## Placeholders to replace
Replace these in the templates (search-and-replace):

| Placeholder | Meaning | Example |
|---|---|---|
| `__APP_NAME__` | App display name | `Go Brain` |
| `__APP_TAGLINE__` | One-line promo (per language) | `Brain puzzles — free & offline` |
| `__APP_ICON__` | Icon path/URL (square PNG/WebP) | `assets/app-icon.png` |
| `__IOS_URL__` | App Store URL | `https://apps.apple.com/app/id6782550523` |
| `__ANDROID_URL__` | Google Play URL | `https://play.google.com/store/apps/details?id=com.example.app` |
| `__CTA_LABEL__` | Button text (per language) | `Get` |

## Quick start (static site)
```bash
# 1. Copy the banner into your site's JS folder
cp templates/app-banner.js   <site>/js/app-banner.js
# (optional) keep CSS separate instead of the self-injected block:
cp templates/app-banner.css  <site>/css/app-banner.css

# 2. Replace placeholders (app name, tagline, icon, store URLs) in app-banner.js

# 3. Include it at the END of <body> on EVERY page:
#    <script src="js/app-banner.js"></script>
```
The script injects the banner as the first child of `<body>`, adds the class `has-appbar` so a
sticky header is pushed down, and self-injects its CSS (no extra `<link>` needed). It re-renders
when a `<select id="langSelect">` changes, if present.

## Behavior contract
- **Mobile web only.** Renders only when the UA is iOS or Android. Returns early on desktop and —
  importantly — inside a native wrapper (see "Native app" below).
- **Right store per OS.** iOS → `__IOS_URL__`, Android → `__ANDROID_URL__`.
- **Persistent by default** (reads as site chrome). Set `DISMISSIBLE = true` in the template to add
  an ✕ that hides it for the session (`sessionStorage`).
- **Never overlaps a sticky header.** The page gets `padding-top` equal to the bar height, and any
  `.header`/`[data-sticky]` is nudged down by the same amount (see CSS `has-appbar` rules).

## Native app guard (important)
If the SAME web build is also wrapped in a native app (Capacitor/Cordova/WebView), do **not** show
an install banner there. Guard it:
```js
// Capacitor example — add near the top of app-banner.js
if (window.Capacitor && window.Capacitor.isNativePlatform && window.Capacitor.isNativePlatform()) return;
```
Or gate on a hostname allowlist (only your real web hosts).

## iOS 12 / old-WebKit safety
The CSS is written to survive WebKit 605 (iOS 12.5):
- Flex `gap` is unsupported there → a `@supports not (inset:0)` fallback applies `margin-left` between
  children. Keep it.
- Do not use the `inset:` shorthand — expand to `top/right/bottom/left`.
- `env(safe-area-inset-*)` is wrapped in `var(..., env(...))` for installed-PWA notch clearance.

See `reference/spa-integration.md` for wiring this into an existing app shell with its own design
tokens (the GoBrain hub does exactly this), and `examples/demo.html` for a runnable preview.
