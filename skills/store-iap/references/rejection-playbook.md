# IAP Rejection Playbook

Exact diagnosis → fix for the two rejections that hit almost every first IAP
submission, plus the recovery paths.

---

## Guideline 2.1(b) — Performance: App Completeness

> "We are unable to complete the review of the app because one or more of the
> In-App Purchase products have not been submitted for review. Specifically, the
> app includes references to subscription but the associated In-App Purchase
> products have not been submitted for review."

### Cause

The app version was submitted **alone**. The products were fully configured but
never added to the submission — they sit at `READY_TO_SUBMIT` while the version
is `WAITING_FOR_REVIEW`. Submitting a version does not pull in its IAPs.

### Diagnose

```bash
node scripts/asc-iap-status.mjs
# VERSION 1.0.0 -> WAITING_FOR_REVIEW      ← version in review
# SUB app.example.pro.monthly -> READY_TO_SUBMIT   ← NOT in review  ❌
```

If products are `READY_TO_SUBMIT` while the version is in review → this is your bug.

### Fix

1. Version page → banner → **"remove this version from review"** → **Remove**.
   (Version goes to `Developer Rejected` / editable. **You lose your queue position.**)
2. Version page → **Add for Review** → **Create New Submission** (or pick the draft).
3. For **each** subscription → its page → **Add for Review** → pick that **same** draft.
4. Subscription **group** page → **Add for Review** → same draft.
5. Each **non-consumable** → **Add for Review** → same draft.
6. Draft panel → warnings gone, item count correct → **Submit for Review**.
7. Confirm **"N Items Submitted"**, then verify via API.

> Apple's message often says "upload a new binary". A new binary is **not**
> required to fix 2.1(b) — the products just need to be in the submission. Only
> upload a new build if you actually changed code.

---

## Guideline 3.1.2(c) — Business: Payments – Subscriptions

> "The submission did not include all the required information for apps offering
> auto-renewable subscriptions. The following information needs to be included in
> the App Store metadata: a functional link to the Terms of Use (EULA)."

### Cause

The **App Store metadata** (not the app) lacks a Terms of Use link. Apple
distinguishes the link *inside the app* (paywall) from the link in the
*App Store listing*. Having it only on the paywall is not enough.

### Fix — metadata (per locale!)

Append to the **App Description** in **every** locale:

```
PRO PLANS
Premium Monthly — $3.99 per month (3-day free trial)
Premium 3 Months — $8.99 per 3 months
Payment is charged to your Apple ID at confirmation of purchase. Subscriptions
renew automatically unless auto-renew is turned off at least 24 hours before the
end of the current period. Manage or cancel anytime in your Apple ID Settings.

Terms of Use (EULA): https://example.com/terms
Privacy Policy: https://example.com/privacy
```

- Standard Apple EULA (always valid):
  `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`
- Also set **Privacy Policy URL** in App Information.
- Prefer your site's **canonical** URL form (`/terms` vs `/terms.html`) — match
  whatever the page's `<link rel="canonical">` says.

### Fix — in the app (paywall)

Show per plan: title, length, price, Terms + Privacy links, auto-renew
disclosure. Most paywalls already satisfy this; the rejection is usually
metadata-only.

### Editing description without the flaky web UI

`PATCH /v1/appStoreVersionLocalizations/{id}` with `{ attributes: { description } }`
works even while the version is `WAITING_FOR_REVIEW`. See `asc-api-recipes.md`.

---

## Recovery: version already in review, products left behind

The most common bad state. Order matters:

```
remove version from review
  → (optional) swap build
  → Add for Review: version   → new/target draft
  → Add for Review: each sub  → same draft
  → Add for Review: group     → same draft
  → Add for Review: each IAP  → same draft
  → Submit for Review  → "N Items Submitted"
```

Removing the version also pulls the previously-submitted products back to
`Developer Rejected` — they must all be re-added.

---

## Swapping the build on a version

Only possible when the version is **not** in review.

1. Remove the version from review (if needed).
2. Version page → **Build** section → **hover the build row** → click the **red
   minus** → build detaches.
3. **Add Build** → radio-select the target build → **Done**.
4. **Save** (button top-right must flip to "✓ Save").
5. Re-assemble the draft (version + all products) → Submit.

The **"Newer Build Available"** dialog on `Add for Review` means the attached
build is older than your newest upload — Cancel and swap the build first if you
want the newer one.

---

## Replying to App Review

- Reply **with** or **after** the resubmission, never before — otherwise
  "included with this app version" is false.
- Use **Save Draft** to park a reply until the resubmission lands.
- If Apple asked for a **screen recording** of the paywall, attach it (record the
  paywall showing title/length/price/Terms/Privacy for each plan).
