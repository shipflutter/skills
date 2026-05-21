# Attribute Contract

This contract describes privacy-safe attributes for Flutter Android, iOS, Flutter Web, and static Web referral demos.

## Device attributes

| Field | Purpose | Availability | Sensitivity | Persistence |
| --- | --- | --- | --- | --- |
| `platform` | Runtime platform label | Android, iOS, Web | Low | Optional local only |
| `platformVersion` | OS/browser version exposed by runtime | Android, iOS, Web | Medium | Avoid long-term storage |
| `appRuntime` | `flutter-android`, `flutter-ios`, `flutter-web`, `static-web` | All | Low | Safe local only |
| `manufacturer` | Device manufacturer where exposed | Android | Medium | Avoid long-term storage |
| `model` | Device model where exposed | Android, iOS | Medium | Avoid long-term storage |
| `isPhysicalDevice` | Simulator/emulator indicator | Android, iOS | Low | Safe local only |
| `browserName` | Browser name | Web | Low | Safe local only |
| `browserVersion` | Browser version | Web | Medium | Avoid long-term storage |
| `userAgent` | Browser user agent | Web | Medium | Display/debug only |
| `screenWidth` | Screen width | Web/Flutter UI | Low | Safe local only |
| `screenHeight` | Screen height | Web/Flutter UI | Low | Safe local only |
| `devicePixelRatio` | Display density | Web/Flutter UI | Low | Safe local only |
| `locale` | Preferred language/locale | All | Low | Safe local only |
| `timezone` | Local timezone label | All | Medium | Avoid long-term storage |
| `colorScheme` | Light/dark preference if available | Flutter UI | Low | Safe local only |

## Referral attributes

| Field | Purpose | Rule |
| --- | --- | --- |
| `initialUrl` | Debug the landing URL | Store locally only |
| `referrer` | Web referral source | Web only, transparent display |
| `utmSource` | Campaign source | Allowlisted |
| `utmMedium` | Campaign medium | Allowlisted |
| `utmCampaign` | Campaign name | Allowlisted |
| `utmTerm` | Campaign term | Allowlisted |
| `utmContent` | Campaign content | Allowlisted |
| `clickIdKeysPresent` | Presence of click ID keys | Store key names, not arbitrary query strings |

## Allowlisted query params

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

## Do not collect

- IP address through third-party services.
- Advertising IDs: IDFA, GAID, AAID.
- IMEI, serial number, MAC address.
- Installed app list.
- Contacts, files, photos, clipboard.
- Precise location.
- Canvas, audio, WebGL, font enumeration fingerprinting.
- Battery/network probing for entropy.
- Unknown query params that may contain secrets.

## Fingerprint guidance

Use the word `fingerprint` carefully. For privacy-safe referral demos, the hash should be a local deterministic debug key derived from the allowed snapshot. It should not be treated as a permanent user identity.

Recommended hash input:

```json
{
  "platform": "web",
  "browserName": "Chrome",
  "locale": "en-US",
  "timezone": "UTC+7",
  "screen": "390x844",
  "devicePixelRatio": 3,
  "referral": {
    "ref": "partner",
    "utm_source": "mobile"
  }
}
```

Recommended metadata:

```json
{
  "privacy": {
    "localOnly": true,
    "thirdPartyIpLookup": false,
    "invasiveFingerprinting": false
  }
}
```
