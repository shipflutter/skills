# IAP Submission Checklist

Work top to bottom. Everything must be true **before** you hit Submit — App
Review only sees what was in the submission.

---

## 1. Code ↔ App Store Connect parity

- [ ] Every product ID referenced in code exists in App Store Connect, **byte-for-byte**.
      (`app.example.pro.monthly` in `ProductID` constants == Product ID in ASC.)
- [ ] No product ID in code that is **missing** in ASC.
      StoreKit does **not** error on unknown IDs — `Product.products(for:)` just
      returns fewer products, so the paywall silently drops that tier while your
      description still advertises it.
- [ ] No product in ASC that the app never offers (dead product confuses review).
- [ ] Local StoreKit config (`Products.storekit`) is **test-only** — it never
      creates real products. Prices there are intent, not truth.

Verify: `node scripts/asc-iap-status.mjs` and diff against your `ProductID` constants.

---

## 2. Per-product readiness (each subscription AND each non-consumable)

For **every** product, in App Store Connect:

- [ ] **Reference Name** set.
- [ ] **Price** set (price schedule / base territory).
- [ ] **Localization** — at least one locale with Display Name + Description.
- [ ] **App Review Screenshot** ← **required; blocks submission if missing.**
      Use a screenshot of the paywall showing this product.
- [ ] Review Notes (optional, but explain how to reach the paywall).
- [ ] Availability / territories set.
- [ ] Status reads **"Prepare for Submission"** (= ready). If it reads
      "Missing Metadata", something above is incomplete.

> **Chicken-and-egg:** you need a paywall screenshot showing a product that only
> renders once the product exists. Create the product first, then screenshot the
> paywall in a build using a StoreKit config or sandbox.

---

## 3. Subscription group (auto-renewable only)

- [ ] The **group itself** has an App Store Localization (Subscription Group
      Display Name). Without it, `Add for Review` fails with
      *"You must add at least one subscription group localization."*
- [ ] Subscription levels/order set.
- [ ] The group is submitted **together with at least one auto-renewable
      subscription from inside it** — a group on its own errors with
      *"New subscription groups must be submitted with an auto-renewable
      subscription from within that group."*

---

## 4. App Store metadata — Guideline 3.1.2(c)

- [ ] **App Description contains a functional Terms of Use (EULA) link.**
      Either Apple's standard EULA:
      `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`
      or your own terms URL (also fine to put a custom EULA in the ASC
      *License Agreement* field).
- [ ] **Privacy Policy URL** set in App Information (per locale) **and** a
      privacy link in the description.
- [ ] Both links **actually load in a browser**. Verify in a real browser —
      many hosts return 403 to bots/CLI fetchers even though the page is live,
      so a failed `curl` is not proof the link is broken.
- [ ] Description discloses, for auto-renewable subscriptions: **title, length,
      price**, free-trial terms, and renewal/cancel wording.
- [ ] **Repeat for every locale** (vi, en-US, …) — a missing EULA link in one
      locale is still a rejection.
- [ ] Description contains **no claim that contradicts the products**:
      - never "no subscription" / "not a subscription" while selling subscriptions;
      - never advertise a tier (Lifetime/Yearly) that doesn't exist in ASC.

---

## 5. In-app paywall — Guideline 3.1.2 (what the app itself must show)

For each auto-renewable option, the paywall must display:

- [ ] Title of the subscription
- [ ] Length / duration ("Billed every month", "3 months")
- [ ] Price (and price-per-unit where useful, e.g. "≈ $3.00/month")
- [ ] Free-trial + auto-renew disclosure
      ("3-day free trial. $3.99/month, auto-renews. Cancel anytime in Settings.")
- [ ] **Functional links to Terms of Use and Privacy Policy** on the paywall
- [ ] **Restore Purchases** reachable (paywall and/or Settings)
- [ ] Paywall degrades safely if a product fails to load (render only what
      `products` returned; never a dead button)

---

## 6. Build

- [ ] Build uploaded and **`VALID`** (check via API — TestFlight UI shows
      "Processing" long after the API says VALID).
- [ ] The **intended** build is attached to the version (watch for the
      *"Newer Build Available"* dialog — it means an older build is attached).
- [ ] Export compliance answered if prompted.

---

## 7. Assemble ONE submission (the step everyone gets wrong)

Add **all** of these into the **same Draft Submission**:

- [ ] App version (with the right build)
- [ ] Every auto-renewable subscription (each one individually)
- [ ] The subscription group
- [ ] Every non-consumable / consumable IAP

Mechanics: on each item's page → **Add for Review** → pick the **existing**
"Draft iOS Submission (N)" (not *Create New Submission*).

- [ ] Draft panel warning area is **empty** (no "Unable to Submit for Review").
- [ ] Item count in the panel == what you expect.

---

## 8. Submit + verify

- [ ] Click **Submit for Review**.
- [ ] Confirmation reads **"N Items Submitted"** with the expected N.
- [ ] Verify with the API:
      - version → `WAITING_FOR_REVIEW`
      - each subscription/IAP → `WAITING_FOR_REVIEW`
      - active `reviewSubmissions` → contains N items
- [ ] If Apple asked for a screen recording (3.1.2), reply to the App Review
      message with it **after** resubmitting, so "included with this version" is true.

> Product `state` can lag right after submitting. The **reviewSubmissions item
> list** is the source of truth — if it holds all N items in
> `WAITING_FOR_REVIEW`, you're good.

---

## Expected item counts (sanity)

| App shape | Items |
|---|---|
| Version + 1 sub + group | 3 |
| Version + 2 subs + group | 4 |
| Version + 2 subs + group + 1 non-consumable | 5 |
| Version only (no IAP) | 1 |
