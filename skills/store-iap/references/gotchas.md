# IAP Gotchas

Traps that cost real submissions. Each one silently produces a wrong result
rather than an obvious error.

---

## 1. A version submission does not include its IAPs

The headline trap. See `rejection-playbook.md` → 2.1(b). Always count the
**"N Items Submitted"** confirmation.

## 2. A subscription group cannot be submitted alone

> *"New subscription groups must be submitted with an auto-renewable
> subscription from within that group."*

Adding only the **group** to the draft leaves Submit disabled. Add the group
**and** at least one subscription from it. In practice: add **every** sub.

## 3. The subscription group needs its own localization

> *"You must add at least one subscription group localization."*

Separate from each subscription's localization. Group page → **Localization** →
Create → locale + **Subscription Group Display Name** (what users see in
Settings → Subscriptions) + App Name display option.

## 4. The first IAP/subscription must ride with an app version

> *"Your first auto-renewable subscription must be submitted with a new app version."*
> *"Your first non-consumable in-app purchase must be submitted with a new app version."*

There is no standalone product submission. The Draft Submission must contain an
app version for the platform.

## 5. StoreKit silently drops unknown product IDs

`Product.products(for: ids)` returns **only** the IDs that exist in App Store
Connect. A product ID in code but missing in ASC → no error, no crash, the
paywall just renders one fewer tier.

Consequences:
- Description/Terms advertise a tier users can never buy.
- A default selection pointing at the missing ID silently falls back.

```swift
// Safe shape: render only what loaded, and fall back for the selection.
ForEach(purchase.products, id: \.id) { productRow($0) }
let product = purchase.products.first { $0.id == selectedID } ?? purchase.products.first
```

Audit: diff `ProductID.all` in code against the product IDs in ASC.

## 6. A product's review screenshot is mandatory

Status "Prepare for Submission" == complete. "Missing Metadata" == something
(usually the App Review screenshot) is absent. You cannot submit without it.

## 7. `inAppPurchasesV2` hides products in `CREATED` state

The modern endpoint returned **zero** IAPs while a non-consumable clearly
existed. The legacy endpoint showed it:

```
GET /v1/apps/{id}/inAppPurchasesV2   → []          ❌ misleading
GET /v1/apps/{id}/inAppPurchases     → [... state=CREATED]  ✅
```

Worse: **v1 and v2 use different resource IDs** for the same product — a v1 id
404s on v2 endpoints. When the two disagree, open the ASC **In-App Purchases**
page and believe the UI's status column.

Do not conclude "the product doesn't exist" from a v2 empty list. Trying to
create it then fails with `409 ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE —
This product ID has already been used`.

## 8. State fields lag; review submission items don't

Right after "N Items Submitted", subscription `state` can still read
`READY_TO_SUBMIT`. That is propagation lag, not failure. Authoritative check:

```
GET /v1/apps/{id}/reviewSubmissions?filter[state]=WAITING_FOR_REVIEW,IN_REVIEW
GET /v1/reviewSubmissions/{id}/items      → item count
```

If the active submission holds all N items, it's submitted.

## 9. TestFlight "Processing" lags the API

`altool` says `UPLOAD SUCCEEDED`, the API says `processingState=VALID`, and the
TestFlight web UI still shows "Processing". Trust the API. Also expect a
1–3 minute ingest gap before a freshly uploaded build appears in the API at all.

## 10. The ASC web UI hangs browser automation

Version / review-submission pages routinely wedge script injection (timeouts on
screenshot/click). Mitigations:

- Verify state via the **API**, not the UI.
- When a tab wedges, open a **fresh tab** — it usually loads.
- Subscription/IAP detail pages are slow: **wait for full render before
  clicking**, or the click lands on nothing and the item is never added (a
  status column still reading `Developer Rejected` after you "added" it is the
  tell — re-check the draft panel).

## 11. Link liveness: 403 ≠ dead

Hosts often block non-browser user agents. `curl`/fetch returning **403 for the
whole site including the homepage** means bot-blocking, not a missing page.
Verify Terms/Privacy links in a **real browser** before "fixing" a non-problem.

## 12. Marketing/product drift

Keep these three in sync — reviewers read all of them:

| Surface | Must match the products in ASC |
|---|---|
| App Description (every locale) | tiers, prices, renewal terms |
| Terms / Privacy pages on the web | tier names ("Yearly" vs "Quarterly") |
| In-app paywall | what actually loads from StoreKit |

Classic drift: description says *"no subscription"* while the app sells
subscriptions; Terms page describes a *Yearly* plan that is really *Quarterly*;
a *Lifetime* tier advertised but absent from ASC.

## 13. Removing from review costs the queue

`remove this version from review` → back of the review queue. Only do it when
the submission is genuinely wrong (missing IAPs, wrong build). Get assembly
right the first time.
