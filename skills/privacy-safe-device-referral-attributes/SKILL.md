---
name: privacy-safe-device-referral-attributes
description: Implement privacy-safe device, browser, and referral attribute collection for Flutter Android, iOS, and Web. Use when adding transparent device info reports, mobile referral attribution, UTM parsing, or local-only fingerprint POCs.
---

# Privacy-Safe Device Referral Attributes

## Use case
Use this skill when an app needs a transparent device/referral attributes screen or POC for Android, iOS, Flutter Web, or plain Web.

This skill is for local debugging, referral attribution prototypes, and anti-abuse signal design. It is not for covert tracking.

## Goals
- Collect only normal platform/browser metadata exposed by the runtime.
- Normalize device and referral attributes into a clear JSON contract.
- Generate a deterministic hash for local demo/debug use.
- Keep collection visible to the user and easy to audit.
- Avoid third-party IP lookup and invasive fingerprinting techniques.

## Allowed attributes
- Platform/runtime: Android, iOS, Web, static Web.
- OS name/version exposed by platform APIs.
- Device model/manufacturer where exposed by `device_info_plus`.
- Browser name/version/user agent on Web.
- Locale/language/timezone.
- Screen size, device pixel ratio, color depth.
- Cookie/storage availability when exposed by browser APIs.
- Referrer and allowlisted referral params.
- Generated local hash from the allowed snapshot.

## Referral param allowlist
Only collect these query keys unless the product explicitly extends the contract:

```text
ref
referral
utm_source
utm_medium
utm_campaign
utm_term
utm_content
click_id
fbclid
gclid
campaign
```

Ignore unlisted params such as `token`, `email`, `session`, `password`, `code`, and `access_token`.

## Disallowed attributes
Do not collect or infer:
- Advertising identifiers such as IDFA or GAID.
- IMEI, serial number, MAC address, installed app list, contacts, files, photos, clipboard, or precise location.
- Canvas, audio, WebGL, font enumeration, battery probing, or other high-entropy fingerprint techniques.
- Public IP via third-party services.
- Hidden network submission without visible UI and explicit product approval.

## IP rule
Client apps and browsers cannot reliably know public IP without a backend. Show IP as unavailable, or fetch only from a documented same-origin backend endpoint. Never call a third-party IP service from the client POC.

## Flutter implementation pattern
1. Add dependencies:
   - `device_info_plus`
   - `crypto`
2. Collect platform metadata through `DeviceInfoPlugin`.
3. Parse referral params from `Uri.base.queryParameters`.
4. Normalize values into a plain JSON-safe map.
5. Hash canonical JSON with SHA-256.
6. Render the full snapshot visibly in the UI.
7. Store locally only if the user/product flow requires it.

## Web implementation pattern
1. Use `navigator`, `screen`, `document.referrer`, and `URLSearchParams`.
2. Use Web Crypto `crypto.subtle.digest('SHA-256', ...)` for a local hash.
3. Render all collected fields and the hash in the page.
4. Do not call third-party endpoints.

## Output contract
A reusable snapshot should include:

```json
{
  "fingerprint": "sha256-hash",
  "collectedAt": "iso-8601",
  "source": "flutter-web|android|ios|static-web",
  "device": {},
  "referral": {},
  "privacy": {
    "localOnly": true,
    "thirdPartyIpLookup": false,
    "invasiveFingerprinting": false
  }
}
```

## Validation checklist
- The UI explains what is collected.
- Unknown query params are ignored.
- `?ref=test&utm_source=mobile&token=secret` includes `ref` and `utm_source`, not `token`.
- No third-party network requests are added.
- The hash is stable when allowed attributes and referral params are unchanged.
- Android, iOS, and Web builds analyze cleanly.
