# App Store Connect API recipes (IAP state)

The ASC web UI lags, caches, and wedges browser automation. The API is the
reliable way to answer "is this actually submitted?".

## Auth — ES256 JWT in ~10 lines

Needs an **App Store Connect API key** (`.p8`, App Manager role) →
Users and Access → Integrations → App Store Connect API.

Node ≥18 (built-in `fetch`, `crypto`):

```js
import { readFileSync } from 'node:fs';
import crypto from 'node:crypto';

const KEY_ID   = process.env.ASC_KEY_ID;      // e.g. ABCD123456
const ISSUER   = process.env.ASC_ISSUER_ID;   // uuid
const p8       = readFileSync(process.env.ASC_KEY_PATH, 'utf8');

const b64u = (o) => Buffer.from(typeof o === 'string' ? o : JSON.stringify(o)).toString('base64url');
const now  = Math.floor(Date.now() / 1000);
const si   = `${b64u({ alg: 'ES256', kid: KEY_ID, typ: 'JWT' })}.` +
             `${b64u({ iss: ISSUER, iat: now, exp: now + 300, aud: 'appstoreconnect-v1' })}`;
// ES256 requires JOSE (R||S) signatures — dsaEncoding:'ieee-p1363'. DER will 401.
const sig  = crypto.sign('sha256', Buffer.from(si), { key: p8, dsaEncoding: 'ieee-p1363' }).toString('base64url');
const token = `${si}.${sig}`;

const get = async (path) =>
  (await fetch('https://api.appstoreconnect.apple.com' + path,
    { headers: { Authorization: `Bearer ${token}` } })).json();
```

> **Gotcha:** `crypto.sign` defaults to DER. Without
> `dsaEncoding: 'ieee-p1363'` every request 401s.

## Endpoints that tell the truth

### Version + attached build

```
GET /v1/apps/{APP_ID}/appStoreVersions?limit=1
      &fields[appStoreVersions]=versionString,appStoreState
      &include=build&fields[builds]=version
```
`appStoreState`: `PREPARE_FOR_SUBMISSION` · `WAITING_FOR_REVIEW` · `IN_REVIEW` ·
`REJECTED` · `DEVELOPER_REJECTED` (= you removed it) · `READY_FOR_SALE`.

### Builds (processing)

```
GET /v1/builds?filter[app]={APP_ID}&limit=5&sort=-uploadedDate
      &fields[builds]=version,processingState,uploadedDate
```
`processingState`: `PROCESSING` → `VALID`. A build takes 1–3 min to even appear
after `altool` reports success.

### Subscriptions

```
GET /v1/subscriptionGroups/{GROUP_ID}/subscriptions
      &fields[subscriptions]=productId,state
```
`state`: `MISSING_METADATA` → `READY_TO_SUBMIT` → `WAITING_FOR_REVIEW` →
`IN_REVIEW` → `APPROVED`. `DEVELOPER_ACTION_NEEDED` after a rejection.

Group localization (required before Add for Review):
```
GET /v1/subscriptionGroups/{GROUP_ID}/subscriptionGroupLocalizations
```
Per-sub review screenshot (required):
```
GET /v1/subscriptions/{SUB_ID}/appStoreReviewScreenshot     # 404/empty = blocked
GET /v1/subscriptions/{SUB_ID}/subscriptionLocalizations
GET /v1/subscriptions/{SUB_ID}/prices?limit=1
```

### Non-consumables / other IAPs — use **v1**, not v2

```
GET /v1/apps/{APP_ID}/inAppPurchases?limit=50        # ✅ shows CREATED-state products
GET /v1/apps/{APP_ID}/inAppPurchasesV2?limit=50      # ❌ can return [] for the same product
```
v1 and v2 use **different ids** for the same product — a v1 id 404s on v2.

### The authoritative submission check

```
GET /v1/apps/{APP_ID}/reviewSubmissions?filter[state]=WAITING_FOR_REVIEW,IN_REVIEW,UNRESOLVED_ISSUES
      &fields[reviewSubmissions]=state,platform
GET /v1/reviewSubmissions/{SUBMISSION_ID}/items?limit=20
```
Item **count** answers "did everything go together?" (version + subs + group +
IAPs). Product `state` fields lag; this does not.

## Editing description (fix 3.1.2 without the flaky UI)

```
GET   /v1/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations
        &fields[appStoreVersionLocalizations]=locale,description
PATCH /v1/appStoreVersionLocalizations/{LOC_ID}
      { "data": { "type": "appStoreVersionLocalizations", "id": "{LOC_ID}",
                  "attributes": { "description": "<full new text>" } } }
```
Works even while the version is `WAITING_FOR_REVIEW`. **Repeat for every
locale.** Read → append your block → PATCH (the API replaces the whole field).

## Uploading a build (no fastlane)

```bash
xcodebuild archive -workspace App.xcworkspace -scheme App \
  -destination 'generic/platform=iOS' -archivePath build/App.xcarchive \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID"

xcodebuild -exportArchive -archivePath build/App.xcarchive \
  -exportOptionsPlist build/ExportOptions.plist -exportPath build/export

cp "$ASC_KEY_PATH" ~/.appstoreconnect/private_keys/   # altool looks here
xcrun altool --upload-app -f build/export/App.ipa -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
rm ~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8   # don't leave keys around
```

`-allowProvisioningUpdates` + the ASC key lets xcodebuild mint the provisioning
profiles for embedded targets (watch/clip/extension) without Xcode's GUI.

## Security

Never commit `.p8` keys, key IDs, issuer IDs, or team IDs. Read them from env
(`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH`, `ASC_APP_ID`) or a gitignored
`.env`. Delete any key you copy into `~/.appstoreconnect/private_keys/`.
