# IAP Setup Guide — end to end

The full path from "no monetization" to "ready to submit". Do these **in order** —
each step silently breaks the next if skipped.

`submission-checklist.md` takes over once everything here is done.

---

## 0. Account prerequisites — the silent killers

These produce **no error in code**. Your paywall just shows nothing.

- [ ] **Paid Applications Agreement is ACTIVE**
      App Store Connect → **Business** → Agreements.
      Until it says *Active*, `Product.products(for:)` returns an **empty array**
      in every environment except a local `.storekit` file. This is the #1 cause
      of "my paywall is blank but the code is right".
- [ ] **Banking** details added and assigned to the agreement.
- [ ] **Tax** forms completed (US + any required regions).
- [ ] Account Holder / Admin has accepted any pending contract updates.
      A newly-published agreement update silently reverts you to *Pending*.

> Quick triage: paywall empty in TestFlight/sandbox but populated with a local
> StoreKit config → it's the agreement, not your code.

---

## 1. Web / legal pages (do this BEFORE metadata)

Guideline 3.1.2 requires **functional** links, and the App Store listing needs
them at submission time. Ship the pages first.

- [ ] **Privacy Policy** page at a stable public URL.
- [ ] **Terms of Use (EULA)** — either:
      - Apple's standard EULA (nothing to host):
        `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`, or
      - your own terms page (then you may also paste a custom EULA into the ASC
        *License Agreement* field).
- [ ] Your Terms page, if you host one, describes each paid tier accurately:
      what it unlocks, **auto-renewing vs one-time**, renewal + cancel wording.
- [ ] Note the **canonical** URL form (`/terms` vs `/terms.html`) — use whatever
      `<link rel="canonical">` says, and use the same in the app + metadata.
- [ ] Verify both load **in a real browser**. A `curl` 403 usually means the host
      blocks bots, not that the page is broken (see `gotchas.md` #11).

**Keep the web copy in sync with the real catalog.** A Terms page describing a
"Yearly" plan when you sell "Quarterly", or a "Lifetime" tier that doesn't exist
in ASC, is drift a reviewer can see.

---

## 2. Design the catalog (decide once — IDs are permanent)

- [ ] **Product ID scheme**: reverse-DNS, stable, boring.
      `app.example.pro.monthly`, `app.example.pro.quarterly`, `app.example.pro.lifetime`
- [ ] ⚠️ **A product ID can never be reused or renamed.** Even a deleted product
      keeps its ID reserved forever — recreating it fails with
      `409 … This product ID has already been used`. Choose carefully.
- [ ] Pick product **types**:
      - *Auto-renewable subscription* → recurring access (must live in a group)
      - *Non-consumable* → one-time permanent unlock ("Lifetime")
      - *Consumable* → credits/coins
- [ ] **Subscription group** design: a user can hold **one subscription per group
      at a time**. Put mutually-exclusive tiers (Monthly / Quarterly / Yearly) in
      the **same** group so users upgrade/downgrade instead of double-paying.
      Levels order = upgrade (higher level) vs downgrade (lower).
- [ ] Decide intro offers: free trial length, intro price, eligibility.

---

## 3. Create the products in App Store Connect

For the **group** (auto-renewables only):
- [ ] Create the subscription group (Reference Name).
- [ ] **Group localization** — Display Name users see in Settings → Subscriptions.
      Missing this blocks *Add for Review* later.
- [ ] Order the levels.

For **each** subscription:
- [ ] Reference Name + **Product ID** (must equal the code constant, byte-for-byte)
- [ ] Duration
- [ ] **Price** (base territory → auto-populates the rest)
- [ ] **Localization**: Display Name + Description
- [ ] Intro offer / free trial (optional)
- [ ] Family Sharing (optional — irreversible once on)
- [ ] **App Review Screenshot** ← required to submit
- [ ] Review Notes: how to reach the paywall

For **each** non-consumable / consumable:
- [ ] Reference Name + Product ID, Price, Localization, **App Review Screenshot**

Target status per product: **"Prepare for Submission"** (= complete).
"Missing Metadata" = something above is absent.

---

## 4. Code (StoreKit 2)

Full templates in **`storekit-code.md`**. The shape that matters:

- [ ] **One source of truth for product IDs** (`enum ProductID { … static let all }`)
      that exactly matches ASC.
- [ ] Load with `Product.products(for: ProductID.all)`.
      ⚠️ Unknown IDs are **silently dropped** — never assume a tier loaded.
- [ ] **Render only what loaded** (`ForEach(products)`), never a hardcoded row
      that can become a dead button.
- [ ] Purchase → **verify** (`VerificationResult`) → unlock → `transaction.finish()`.
- [ ] **`Transaction.updates` listener started at app launch** (before any
      purchase) — otherwise Ask-to-Buy/interrupted purchases are lost.
- [ ] Entitlement from `Transaction.currentEntitlements` (not a local bool).
- [ ] **Restore Purchases** control (`AppStore.sync()`) — Apple requires it.
- [ ] Paywall shows, per plan: **title, length, price**, trial + auto-renew text,
      and **functional Terms + Privacy links** (Guideline 3.1.2).

Using **RevenueCat** instead? The ASC-side setup (0–3), the paywall disclosure
rules, and the entire submission flow are **identical** — RevenueCat only
replaces §4. You still create the products in ASC and still must add each one to
the submission.

---

## 5. Test before you submit

**Local (fastest, no ASC round-trip):**
- [ ] Add a **StoreKit Configuration file** (`Products.storekit`) — File → New →
      StoreKit Configuration. Either sync it from ASC or define products locally.
- [ ] Xcode → Edit Scheme → Run → Options → **StoreKit Configuration** → pick it.
- [ ] ⚠️ This file is **test-only** — it never creates real products, and it will
      happily show a tier that doesn't exist in ASC. Prices there are intent,
      not truth. Never treat a working local paywall as proof.

**Sandbox (real StoreKit, real ASC products):**
- [ ] Create a **Sandbox Tester** (Users and Access → Sandbox → Testers).
- [ ] Sign out of the real App Store account on device; sign in when prompted at purchase.
- [ ] Verify: products load, purchase, entitlement unlocks, **restore**, and
      subscription renew/expire (sandbox durations are compressed).
- [ ] Empty products in sandbox but fine locally → go back to **§0 agreements**.

**TestFlight:** closest to production; confirms the real ASC catalog loads.

---

## 6. The review screenshot chicken-and-egg

Each product needs an App Review screenshot **of the paywall showing that
product** — but the paywall only renders products that exist.

Order that works:
1. Create the product in ASC (§3).
2. Run the app with a StoreKit config or sandbox so the tier renders.
3. Screenshot the paywall.
4. Attach it to that product in ASC.

---

## 7. Metadata, then submit

- [ ] App Description (**every locale**): subscription disclosure + **Terms of Use
      (EULA) link** + Privacy link.
- [ ] Privacy Policy URL set in App Information.
- [ ] No copy that contradicts the catalog.

→ Then work **`submission-checklist.md`**, and remember the one rule: the app
version and **every** product must go into the **same Draft Submission**.

---

## Fast triage

| Symptom | Cause |
|---|---|
| Paywall empty in sandbox/TestFlight, fine locally | Paid Applications Agreement not Active (§0) |
| One tier missing from paywall, no error | Product ID in code missing/typo'd in ASC (§2, gotchas #5) |
| `Add for Review` errors on the group | Group localization missing (§3) |
| Product can't be submitted | No App Review screenshot (§3/§6) |
| Rejected 2.1(b) | Products not added to the submission (`rejection-playbook.md`) |
| Rejected 3.1.2(c) | No Terms of Use (EULA) link in App Description (§1/§7) |
| `409 product ID already used` | ID was used before — IDs are permanent (§2) |
