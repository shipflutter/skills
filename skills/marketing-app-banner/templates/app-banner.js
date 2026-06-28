/* Marketing "Get the app" banner — self-contained, dependency-free.
 *
 * A native-style smart-app-banner pinned to the top on phones, hidden on desktop.
 * Detects iOS vs Android and sends the CTA to the right store. Injects itself as
 * the first child of <body>, adds `has-appbar` so a sticky header is nudged down,
 * and self-injects its CSS. Re-renders when a <select id="langSelect"> changes.
 *
 * SETUP: replace the __PLACEHOLDERS__ below, then include on every page:
 *   <script src="js/app-banner.js"></script>
 */
(function () {
  "use strict";

  // ---- config ------------------------------------------------------------
  var TITLE = "__APP_NAME__";
  var STORE = {
    ios: "__IOS_URL__",
    android: "__ANDROID_URL__",
  };
  // Per-language tagline + CTA. Trim to one language if you don't need i18n.
  var T = {
    en: { sub: "__APP_TAGLINE__", cta: "__CTA_LABEL__" },
    vi: { sub: "__APP_TAGLINE__", cta: "__CTA_LABEL__" },
  };
  var DISMISSIBLE = false; // set true to add an ✕ that hides it for the session
  var DISMISS_KEY = "appbanner.dismissed";

  // ---- native-app guard (uncomment if the same build is wrapped natively) --
  // if (window.Capacitor && window.Capacitor.isNativePlatform && window.Capacitor.isNativePlatform()) return;

  // ---- platform sniff ----------------------------------------------------
  function detectOs() {
    var ua = navigator.userAgent || "";
    if (/iPad|iPhone|iPod/i.test(ua) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1)) return "ios";
    if (/android/i.test(ua)) return "android";
    return "desktop";
  }
  var os = detectOs();
  if (os !== "ios" && os !== "android") return; // desktop: don't inject

  try { if (DISMISSIBLE && sessionStorage.getItem(DISMISS_KEY)) return; } catch (e) {}

  // ---- i18n helper -------------------------------------------------------
  function currentLang() {
    var sel = document.getElementById("langSelect");
    if (sel && T[sel.value]) return sel.value;
    var code = ((navigator.language || "en") + "").toLowerCase().split("-")[0];
    return T[code] ? code : "en";
  }
  function esc(s) {
    return String(s).replace(/[&<>"]/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
    });
  }

  // ---- styles (self-injected; iOS-12 safe) -------------------------------
  var CSS =
    ":root{--ab-h:60px;--ab-bg:#fff;--ab-fg:#1a1a1a;--ab-sub:#6e6e6e;--ab-bd:#e5e7eb;--ab-btn-bg:#1a1a1a;--ab-btn-fg:#fff;--ab-radius:8px}" +
    "@media (prefers-color-scheme:dark){:root{--ab-bg:#0e0e10;--ab-fg:#fff;--ab-sub:#9ca3af;--ab-bd:#28282c;--ab-btn-bg:#fff;--ab-btn-fg:#0e0e10}}" +
    ".app-banner{position:fixed;top:0;left:0;right:0;z-index:1000;box-sizing:border-box;display:flex;align-items:center;gap:12px;" +
    "height:calc(var(--ab-h) + var(--ab-saa, env(safe-area-inset-top,0px)));" +
    "padding:var(--ab-saa, env(safe-area-inset-top,0px)) 14px 0;background:var(--ab-bg);border-bottom:1px solid var(--ab-bd);" +
    "font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif}" +
    ".app-banner .ab-icon{width:40px;height:40px;border-radius:var(--ab-radius);flex:0 0 auto;object-fit:cover;box-shadow:0 1px 2px rgba(0,0,0,.12)}" +
    ".app-banner .ab-text{flex:1 1 auto;min-width:0;display:flex;flex-direction:column;line-height:1.25}" +
    ".app-banner .ab-text b{font-size:15px;font-weight:700;color:var(--ab-fg)}" +
    ".app-banner .ab-text span{font-size:12px;color:var(--ab-sub);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}" +
    ".app-banner .ab-cta{flex:0 0 auto;background:var(--ab-btn-bg);color:var(--ab-btn-fg);border-radius:var(--ab-radius);" +
    "padding:9px 18px;font-weight:700;font-size:14px;text-decoration:none;white-space:nowrap}" +
    ".app-banner .ab-cta:active{opacity:.9}" +
    ".app-banner .ab-x{border:0;background:none;color:var(--ab-sub);font-size:16px;line-height:1;padding:4px 6px;cursor:pointer;flex:0 0 auto}" +
    /* push the page + a sticky header below the fixed bar */
    "body.has-appbar{padding-top:calc(var(--ab-h) + var(--ab-saa, env(safe-area-inset-top,0px)))}" +
    "body.has-appbar .header,body.has-appbar [data-sticky]{top:calc(var(--ab-h) + var(--ab-saa, env(safe-area-inset-top,0px)))}" +
    /* old-WebKit (iOS 12) has no flex gap → fall back to margins */
    "@supports not (inset:0){.app-banner>*+*{margin-left:12px}}";

  function injectStyle() {
    if (document.getElementById("app-banner-style")) return;
    var st = document.createElement("style");
    st.id = "app-banner-style";
    st.appendChild(document.createTextNode(CSS));
    (document.head || document.documentElement).appendChild(st);
  }

  // ---- render ------------------------------------------------------------
  // Resolve the icon from the page's own logo if the placeholder wasn't set,
  // so the path is correct on root + nested pages.
  var ICON = "__APP_ICON__";
  if (ICON.indexOf("__APP") === 0) ICON = (document.querySelector(".logo, .brand img") || {}).src || "app-icon.png";

  var host = document.createElement("div");
  host.className = "app-banner";

  function render() {
    var d = T[currentLang()] || T.en;
    host.innerHTML =
      '<img class="ab-icon" src="' + esc(ICON) + '" alt="" width="40" height="40" />' +
      '<span class="ab-text"><b>' + esc(TITLE) + "</b><span>" + esc(d.sub) + "</span></span>" +
      '<a class="ab-cta" href="' + STORE[os] + '" rel="noopener" target="_blank">' + esc(d.cta) + "</a>" +
      (DISMISSIBLE ? '<button class="ab-x" type="button" aria-label="Dismiss">✕</button>' : "");
    if (DISMISSIBLE) {
      host.querySelector(".ab-x").addEventListener("click", function () {
        try { sessionStorage.setItem(DISMISS_KEY, "1"); } catch (e) {}
        document.body.classList.remove("has-appbar");
        host.remove();
      });
    }
  }

  function mount() {
    injectStyle();
    document.body.insertBefore(host, document.body.firstChild);
    document.body.classList.add("has-appbar");
    render();
    var sel = document.getElementById("langSelect");
    if (sel) sel.addEventListener("change", render);
  }

  if (document.body) mount();
  else document.addEventListener("DOMContentLoaded", mount);
})();
