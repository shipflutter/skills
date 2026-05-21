# Example Prompts

## Add a Flutter device/referral attributes screen

```text
Use the `privacy-safe-device-referral-attributes` skill.

Add a Flutter screen that displays privacy-safe device and referral attributes for Android, iOS, and Flutter Web.

Requirements:
- Use `device_info_plus` for platform metadata.
- Use `crypto` for a local SHA-256 hash.
- Parse only allowlisted referral params: ref, referral, utm_source, utm_medium, utm_campaign, utm_term, utm_content, click_id, fbclid, gclid, campaign.
- Ignore params like token, email, access_token, session, and password.
- Do not call third-party IP or enrichment APIs.
- Do not use canvas/audio/WebGL/font fingerprinting.
- Show the full collected JSON in the UI.
- Report changed files and commands run.
```

## Create a static Web device demo

```text
Use the `privacy-safe-device-referral-attributes` skill.

Create a standalone `web/device.html` page with plain HTML, CSS, and JavaScript.

Requirements:
- Collect browser-accessible metadata only: userAgent, platform, language, timezone, screen size, devicePixelRatio, colorDepth, cookieEnabled, referrer.
- Parse only allowlisted referral query params.
- Generate a SHA-256 hash using Web Crypto.
- Render a privacy notice and full JSON output.
- Do not send data to any server.
```

## Audit an existing fingerprint implementation

```text
Use the `privacy-safe-device-referral-attributes` skill.

Audit the current device fingerprint/referral implementation.

Check for:
- Third-party IP services.
- Canvas/audio/WebGL/font entropy collection.
- Storage of sensitive query params.
- Hidden network submission.
- Advertising IDs, serial numbers, installed apps, precise location, contacts, files, or clipboard access.

Return:
- Safe fields.
- Risky fields.
- Required removals.
- Recommended privacy-safe replacement.
```

## Convert invasive tracking to privacy-safe attributes

```text
Use the `privacy-safe-device-referral-attributes` skill.

Refactor an invasive browser fingerprint into a transparent local-only attribute snapshot.

Requirements:
- Remove canvas/audio/WebGL/font probes.
- Keep only low-risk platform, locale, screen, browser, and allowlisted referral fields.
- Hash canonical JSON locally.
- Explain IP limitations and remove third-party IP calls.
- Add tests for referral allowlist filtering.
```
