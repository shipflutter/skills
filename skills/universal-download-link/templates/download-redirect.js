// Optional: soft auto-redirect for an existing informational /download/ page.
//
// Unlike /get/ (which replaces instantly in <head>), this keeps your rich
// download page visible and sends MOBILE visitors to the right store after a
// short delay, with a visible notice + a "Stay on this page" escape hatch.
//   iOS     -> App Store
//   Android -> Google Play
//   Desktop -> stays on the page (no redirect)
// Escape hatches: ?stay=1 / ?noredirect skips it; redirects at most once per
// session so Back doesn't trap. Replace __IOS_URL__ / __ANDROID_URL__.
(function () {
  "use strict";

  var params = new URLSearchParams(location.search);
  if (params.has("stay") || params.has("noredirect")) return;

  var ua = navigator.userAgent || "";
  var isAndroid = /Android/i.test(ua);
  var isIOS =
    /iPad|iPhone|iPod/i.test(ua) ||
    (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);
  if (!isAndroid && !isIOS) return; // desktop: keep the informational page

  var PLAY = "__ANDROID_URL__";
  var APP_STORE = "__IOS_URL__";
  var target = isAndroid ? PLAY : APP_STORE;
  var label = isAndroid ? "Google Play" : "App Store";

  var KEY = "dlRedirected";
  try { if (sessionStorage.getItem(KEY)) return; } catch (e) {}

  var DELAY = 1200;
  var cancelled = false;
  function remember() { try { sessionStorage.setItem(KEY, "1"); } catch (e) {} }

  function showNotice() {
    var bar = document.createElement("div");
    bar.setAttribute("role", "status");
    bar.style.cssText =
      "position:fixed;left:0;right:0;bottom:0;z-index:9999;display:flex;gap:12px;flex-wrap:wrap;" +
      "align-items:center;justify-content:center;padding:12px 16px;background:#111;color:#fff;" +
      "font:14px/1.4 -apple-system,system-ui,sans-serif";
    bar.innerHTML =
      "<span>Opening " + label + "…</span>" +
      '<a href="' + target + '" rel="noopener" style="color:#7db1ff">Tap here if it doesn’t open</a>' +
      '<button type="button" style="background:none;border:1px solid #555;color:#fff;border-radius:6px;padding:6px 10px">Stay on this page</button>';
    document.body.appendChild(bar);
    bar.querySelector("a").addEventListener("click", remember);
    bar.querySelector("button").addEventListener("click", function () {
      cancelled = true; remember(); bar.remove();
    });
  }

  function go() {
    if (document.body) showNotice();
    else document.addEventListener("DOMContentLoaded", showNotice);
    setTimeout(function () {
      if (cancelled) return;
      remember();
      location.href = target;
    }, DELAY);
  }
  go();
})();
