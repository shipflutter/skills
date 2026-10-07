---
name: store-iap
description: Get in-app purchases and subscriptions through Apple App Review. Use when an app sells IAP/subscriptions and you are preparing an App Store submission, wiring a paywall, or fixing an IAP rejection — Guideline 2.1(b) "In-App Purchase products have not been submitted for review", Guideline 3.1.2(c) missing Terms of Use (EULA) / subscription disclosure, "New subscription groups must be submitted with an auto-renewable subscription from within that group", subscriptions stuck in READY_TO_SUBMIT, or a version already Waiting for Review without its IAPs attached.
---

# Store IAP Review — ship in-app purchases past App Review

Everything needed to take an app that sells IAP/subscriptions from "the paywall
works locally" to "app + every product accepted by App Review", plus the recovery
path when Apple rejects for IAP reasons.

> **Scope.** `store-release` owns the *first submission* (metadata, screenshots,
> fastlane). This skill owns the **IAP/subscription half**: product setup, the
> paywall + metadata disclosure rules, and the submission mechanics that
> silently drop your products if you get them wrong.

## The one rule that causes most IAP rejections

**Submitting an app version does NOT submit your IAPs.**

App Store Connect treats the app version and every IAP/subscription as
**separate items**. You must `Add for Review` the app version **and each
individual product** into the **same Draft Submission**, then submit once — all
items go together. Submit the version alone and Apple reviews an app whose
paywall references products that were never submitted → **Guideline 2.1(b)**.

The confirmation dialog tells you if you got it right: it says **"N Items
Submitted"**. Count N. Version + 2 subscriptions + 1 non-consumable + 1
subscription group = **5**.

## When to use

- **Setting up IAP from scratch** — agreements, products, StoreKit code, testing.
- An app that sells IAP/subscriptions is about to be submitted.
- Rejection cites **2.1(b)** (products not submitted) or **3.1.2(c)** (missing
  EULA / subscription info).
- A paywall is **empty** / a tier is missing with no error in the logs.
- `Add for Review` is greyed out or errors.
- Subscriptions sit at `READY_TO_SUBMIT` while the version is `WAITING_FOR_REVIEW`.
- You need to swap the build on a version that's already in review.

## Route by task

| Task | Start here |
|---|---|
| Building IAP from zero | `references/setup-guide.md` (agreements → web/legal → products → code → test) |
| Writing/reviewing the StoreKit code + paywall | `references/storekit-code.md` |
| About to submit | `references/submission-checklist.md` |
| Rejected (2.1(b) / 3.1.2(c)) | `references/rejection-playbook.md` |
| "This makes no sense" | `references/gotchas.md` |
| "Is it actually submitted?" | `scripts/asc-iap-status.mjs` |

## Quick start

```bash
# 0. Verify what App Store Connect actually thinks (the web UI lags and lies).
#    Needs an ASC API key (.p8) with App Manager role.
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export ASC_KEY_PATH=/path/to/AuthKey_$ASC_KEY_ID.p8
export ASC_APP_ID=1234567890

node scripts/asc-iap-status.mjs        # version + build + every product's state
```

Then work the checklist:

1. **Every product ready** → price + localization + **App Review screenshot**.
2. **Subscription group** has its own localization (display name).
3. **Metadata** → Terms of Use (EULA) link in the App Description, Privacy Policy
   URL set, subscription disclosed, no claims that contradict the real products.
4. **Paywall** shows title + length + price + Terms/Privacy links + auto-renew text.
5. **Assemble one Draft Submission**: app version + every product + the group.
6. **Submit** → confirm the dialog says the right item count.
7. **Verify** with `asc-iap-status.mjs` → products flip to `WAITING_FOR_REVIEW`.

## What's in this skill

| File | Purpose |
|------|---------|
| `references/setup-guide.md` | **End-to-end setup**: account agreements (the silent killers), web/legal pages, catalog design, creating products in ASC, code, local + sandbox testing, the review-screenshot chicken-and-egg. **Start here when building IAP from scratch.** |
| `references/storekit-code.md` | StoreKit 2 templates: product-ID source of truth, purchase manager (updates listener, verify, finish, entitlements, restore), a paywall that satisfies 3.1.2, local `.storekit` config, pre-submit code audit. |
| `references/submission-checklist.md` | The tickable pre-submit checklist: per-product readiness, metadata (3.1.2), paywall requirements, assembly + submit. **Read this before every submission.** |
| `references/rejection-playbook.md` | Exact fixes for 2.1(b) and 3.1.2(c), the recovery path when the version is already in review without its IAPs, and how to swap a build. |
| `references/gotchas.md` | The traps that cost real submissions: group-needs-a-sub, group localization, silent StoreKit product drops, v1/v2 API disagreement, state fields that lag. |
| `references/asc-api-recipes.md` | ES256 JWT + the endpoints that tell the truth about build/product/submission state. |
| `scripts/asc-iap-status.mjs` | Runnable: prints version state, attached build, every subscription + IAP state, and the active review submission's item count. |
| `assets-store/` | **Unrelated to Apple IAP — do not read it for App Review guidance.** A self-contained POC of a *web* skill marketplace (browse/compare skills, **SePay** bank-transfer/QR checkout, webhook-confirmed unlock): static client + Node/TS backend + its own user-story/technical-design docs. Parked here as a payments reference; it has no bearing on StoreKit, IAP products, or the submission flow above. `node_modules`/`dist`/`coverage`/`dist-deploy` are gitignored — run `npm install` in `assets-store/backend` to work on it. |

## Non-negotiables (learned the hard way)

- **Paid Applications Agreement must be Active** before any product loads.
  Without it `Product.products(for:)` returns `[]` in sandbox/production with no
  error — the #1 cause of "blank paywall, correct code".
- **Product IDs are permanent.** Never reusable, never renamable — even after
  deletion. Recreating one fails `409 … already been used`.
- **A product with no App Review screenshot cannot be submitted.** Screenshot the
  paywall showing that product.
- **The first subscription/IAP must ride with an app version.** There is no way to
  submit products on their own.
- **Marketing must match reality.** Never claim "no subscription" while selling
  one, and never advertise a product (e.g. a Lifetime tier) that does not exist
  in App Store Connect — StoreKit silently omits unknown product IDs, so the app
  ships without it while the description still promises it.
- **Trust the API, not the ASC web UI.** TestFlight shows "Processing" long after
  the API says `VALID`; product `state` fields lag a submission. The
  `reviewSubmissions` item list is authoritative.
- **Removing a version from review costs your queue position.** Get the assembly
  right the first time.
