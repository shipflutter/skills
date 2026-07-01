# Integrating the banner into an SPA / in-app web hub

The static `templates/app-banner.js` injects into `<body>` and assumes a normal document scroll.
A single-page app or game hub usually has its own fixed, internally-scrolling shell with a sticky
title bar. Wire the banner into that shell instead of body-injecting. This mirrors the GoBrain hub.

## Shape of the integration

Given a shell like:
```html
<div id="hub">                 <!-- position:fixed; inset:0; overflow-y:auto -->
  <header class="topbar">…</header>   <!-- position:sticky; top:0 -->
  <div class="list">…</div>
</div>
```

1. **Render the banner as the FIRST child of the scroll container** (`#hub`), before the sticky
   header — not in `<body>`:
   ```js
   container.querySelector(".app-banner")?.remove();
   const banner = makeBanner(os);          // returns the element (see app-banner.js render())
   if (banner) {
     container.insertBefore(banner, container.firstChild);
     container.classList.add("has-appbar");
   } else {
     container.classList.remove("has-appbar");
   }
   ```
   Re-run this whenever the view or locale changes so the CTA text follows the language.

2. **Offset the scroll container, not `<body>`.** Because the banner is `position:fixed` (viewport-
   relative) but the scroll container is its own `overflow:auto` box, pad the container so its sticky
   header parks just below the bar:
   ```css
   #hub.has-appbar { padding-top: calc(60px + var(--saa-top, env(safe-area-inset-top,0px))); }
   /* if the topbar already adds its own safe-area pad, drop it when the banner covers it */
   #hub.has-appbar .topbar { padding-top: 18px; }
   ```
   With container `padding-top = bar height`, a `position:sticky; top:0` header sticks at the
   content-box edge — exactly under the fixed bar. Verified: bar 0–60px, header parks at 60px, no
   overlap.

3. **Auto-hide during full-screen views.** If the banner lives inside `#hub` and you `display:none`
   the hub when a game/detail opens, the fixed banner hides with it for free. Give it a `z-index`
   above the title bar but below any full-screen overlay.

## Native wrapper guard
In a Capacitor/Cordova hub, skip the banner inside the native app:
```js
import { Capacitor } from "@capacitor/core";
if (Capacitor.isNativePlatform()) return null;
```

## Theming with design tokens
Replace the `--ab-*` values with your app's CSS variables (surface, border, text, accent) so the
banner matches light/dark automatically. The GoBrain hub reuses `--hb/--hbd/--ht/--hm/--acc/--accd`.

## iOS 12 reminders (if you ship to old WebKit)
- Keep the `@supports not (inset:0){ .app-banner>*+* { margin-left:12px } }` flex-gap fallback.
- Never use the `inset:` shorthand — expand to `top/right/bottom/left`.
- Keep `env(safe-area-inset-top)` wrapped as `var(--saa-top, env(...))`.
