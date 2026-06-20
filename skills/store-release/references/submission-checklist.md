# Submission Checklist — every task to get a Flutter app submitted

A do-this-in-order task list for a **first** App Store + Google Play submission.
Tick each box. Items marked **⚠ web-UI** cannot be reliably done via API/fastlane —
do them in the console. Items marked **🔒 declaration** are legal/business
attestations: never fabricate the answers, get them from the app owner.

Companion docs: [first-release-checklist.md](first-release-checklist.md) (the
walkthrough), [fastlane-gotchas.md](fastlane-gotchas.md) (env fixes),
[prompts.md](prompts.md) (ready prompts).

---

## A. Accounts & signing (one-time)

- [ ] Apple Developer Program active; team id noted (`XXXXXXXXXX`)
- [ ] Google Play Developer account active
- [ ] App Store Connect API key created; `.p8` saved to `~/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8`
- [ ] Google Play service-account JSON created (role: Release manager); path in `.env.prod`
- [ ] iOS distribution cert + App Store provisioning profile available (or Xcode automatic signing)
- [ ] Android upload/signing keystore available; Play App Signing enabled
- [ ] All secrets gitignored; nothing committed to the app repo

---

## B. App records (one-time)

- [ ] **⚠ web-UI** App Store Connect app record created (My Apps → New App). The API key **cannot** create it (403).
- [ ] **⚠ web-UI** Play Console app created
- [ ] Bundle id / applicationId match the records and are final (permanent once published)

---

## C. Listing content

- [ ] iOS metadata files per locale in `ios/fastlane/metadata/<locale>/`
- [ ] Android metadata per locale in `android/fastlane/metadata/android/<locale>/`
- [ ] iOS screenshots in `ios/fastlane/screenshots/<locale>/` for required device sizes
- [ ] Android graphics: icon, feature graphic, phone + 7"/10" tablet screenshots
- [ ] Copy is within each store's character limits (ASO)

### Required screenshot display types (verify these exact ones aren't flagged "missing")
- [ ] iPhone 6.9"/6.7" — `APP_IPHONE_67`
- [ ] iPad 13"/12.9" — `APP_IPAD_PRO_3GEN_129` (only if the app supports iPad)
- [ ] After upload, **re-check via the review-submission validator** — screenshots can show a count in the set yet still be flagged "missing" if the asset upload didn't finalize. Re-upload or re-drop in the web UI until the validator is clean.

---

## D. Build

- [ ] `version:` bumped in `pubspec.yaml`
- [ ] iOS binary built + uploaded (no-codesign archive → `xcodebuild -exportArchive` → `xcrun altool --upload-app`)
- [ ] iOS build reaches state **VALID** on App Store Connect (processing takes 5–30 min — poll before attaching)
- [ ] iOS build **attached** to the App Store version (`version.select_build(build_id:)`); version string must equal the build's `CFBundleShortVersionString`
- [ ] Android AAB built + uploaded to a track (`fastlane internal`)

---

## E. App Store version requirements (the blockers that stop "Submit")

These are all required before a first submission and each one fails the review-submission validator if missing:

- [ ] **Copyright** set on the version (`version.update(attributes: {copyright: "<year holder>"})`) — *API-settable*
- [ ] **🔒 Content Rights** declaration (`app.update(attributes: {contentRightsDeclaration: "DOES_NOT_USE_THIRD_PARTY_CONTENT" | "USES_THIRD_PARTY_CONTENT"})`) — *API-settable, but ask the owner*
- [ ] **🔒 Age Rating** questionnaire — *API-settable* via `patch_age_rating_declaration` on the **app-info-level** declaration id. Set every enum descriptor to `"NONE"` and every boolean to `false` for a 4+ rating. **Gotcha:** the API also requires `ageAssurance` (boolean) and `ageRatingOverrideV2` even though they aren't in the "missing attribute" error list. The declaration moved from the version to the app/app-info level — `ageRatingDeclaration` is no longer a valid relationship on `appStoreVersion`.
- [ ] **🔒 ⚠ web-UI App Privacy** — data-collection answers must be **published**. If the app collects any data, this needs specific data-type declarations; do it in the web UI and click Publish. Don't fabricate data types.
- [ ] **⚠ web-UI Pricing** — set a price (e.g. Free). "App is not eligible for submission until pricing has been set." The new price-schedule API is fragile; the web UI is one dropdown.
- [ ] Export compliance answered (`ITSAppUsesNonExemptEncryption` in Info.plist → auto-marks the build exempt)

---

## F. Submit (iOS)

- [ ] Create/get the review submission: `app.create_review_submission(platform: IOS)`
- [ ] Add the version: `submission.add_app_store_version_to_review_items(app_store_version_id:)` — this call returns the **full list of remaining blockers** if the version isn't ready; use it as the validator
- [ ] `submission.submit_for_review`
- [ ] Confirm version state moves to `WAITING_FOR_REVIEW`

## F. Submit (Android)

- [ ] **⚠ web-UI** Complete every Dashboard task (data safety, content rating, target audience, privacy policy, store listing) — Play blocks the first production release until all are green
- [ ] Promote the tested internal build: `fastlane promote_to_production` (or via Console)

---

## G. Known first-submission rejections (fix before/after submit)

- [ ] **90771** — `UIBackgroundModes` without a matching capability → remove the unused mode
- [ ] **ITMS-90683** — missing usage-description string (e.g. `NSPhotoLibraryUsageDescription`) → add it
- [ ] **"No data" at `fetch_app_store_review_detail`** — first version has no review-detail object → `version.create_app_store_review_detail(attributes: {demo_account_required: false})`
- [ ] **`invalid byte sequence in US-ASCII`** in deliver → `export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8`
- [ ] **fastlane/`gh_inspector` missing** → use Homebrew ruby + `bundle exec`

---

## Quick reference: what's API-settable vs web-UI only

| Task | API (spaceship/fastlane) | Web UI only |
|------|:---:|:---:|
| Create app record | ✗ (403) | ✅ |
| Metadata + screenshots | ✅ (deliver) | ✅ |
| Build upload + attach | ✅ | ✅ |
| Copyright | ✅ | ✅ |
| Content rights | ✅ | ✅ |
| Age rating | ✅ | ✅ |
| **App Privacy (data usage)** | ⚠ unreliable | ✅ |
| **Pricing** | ⚠ fragile | ✅ |
| Submit for review | ✅ | ✅ |
