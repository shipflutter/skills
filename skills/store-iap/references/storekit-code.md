# StoreKit 2 — code templates

Copy-adapt shapes for the code half of `setup-guide.md` §4. Swift / StoreKit 2
(iOS 15+). Every choice here exists to avoid a specific rejection or silent bug.

---

## 1. Product IDs — one source of truth

```swift
enum ProductID {
    static let monthly   = "app.example.pro.monthly"
    static let quarterly = "app.example.pro.quarterly"
    static let lifetime  = "app.example.pro.lifetime"   // non-consumable

    /// Everything the paywall may offer. Must match App Store Connect exactly.
    static let all: [String] = [monthly, quarterly, lifetime]
}
```

Audit this list against ASC before every submission — an ID here that is missing
there is dropped **silently** (see `gotchas.md` #5).

---

## 2. Purchase manager

```swift
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedIDs: Set<String> = []
    @Published private(set) var isLoadingProducts = false
    @Published var purchaseError: String?

    var isPro: Bool { !purchasedIDs.isEmpty }

    private var updatesTask: Task<Void, Never>?

    init() {
        // MUST start before any purchase can happen: this delivers Ask-to-Buy
        // approvals, interrupted purchases, renewals and refunds. Without it
        // those transactions are never finished and can replay forever.
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
    }

    deinit { updatesTask?.cancel() }

    // MARK: Load

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            // StoreKit returns ONLY the IDs that exist in App Store Connect.
            // Fewer products than requested = a config gap, never an error.
            products = try await Product.products(for: ProductID.all)
                .sorted { $0.price < $1.price }
            #if DEBUG
            let missing = Set(ProductID.all).subtracting(products.map(\.id))
            if !missing.isEmpty { print("⚠️ not in App Store Connect: \(missing)") }
            #endif
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: Purchase

    func purchase(_ product: Product) async {
        do {
            switch try await product.purchase() {
            case .success(let verification):
                await handle(verification)
            case .userCancelled:
                break
            case .pending:
                // Ask-to-Buy / SCA — resolves later via Transaction.updates.
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    /// Restore. Apple REQUIRES a user-invokable restore for non-consumables/subs.
    func restore() async {
        do { try await AppStore.sync() } catch { purchaseError = error.localizedDescription }
        await refreshEntitlements()
    }

    // MARK: Entitlements

    /// Source of truth — never a locally persisted bool.
    func refreshEntitlements() async {
        var owned: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let t) = result else { continue }
            if t.revocationDate == nil { owned.insert(t.productID) }
        }
        purchasedIDs = owned
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return } // drop unverified
        await refreshEntitlements()
        await transaction.finish()   // never skip: unfinished transactions replay
    }
}
```

### Rules encoded above

| Rule | Why |
|---|---|
| `Transaction.updates` listener at launch | Ask-to-Buy / interrupted purchases arrive out-of-band |
| `case .verified` only | `.unverified` = failed signature check |
| `await transaction.finish()` | Unfinished transactions redeliver forever |
| Entitlement from `currentEntitlements` | Survives reinstall/new device; a local bool doesn't |
| `AppStore.sync()` restore | Apple requires a restore path |
| Render only loaded products | A missing product must not leave a dead button |

---

## 3. Paywall — the Guideline 3.1.2 surface

Must show, **per auto-renewable plan**: title · length · price · trial/auto-renew
disclosure · functional **Terms** + **Privacy** links · a **Restore** control.

```swift
struct PaywallView: View {
    @EnvironmentObject var purchase: PurchaseManager
    @State private var selectedID: String?

    // Never default to a hardcoded ID — it may not have loaded.
    private var selected: Product? {
        purchase.products.first { $0.id == selectedID } ?? purchase.products.first
    }

    var body: some View {
        VStack(spacing: 16) {
            if purchase.products.isEmpty {
                if purchase.isLoadingProducts { ProgressView() }
                else { Text("Products unavailable. Try again later.") }   // agreement/config gap
            } else {
                ForEach(purchase.products, id: \.id) { product in
                    Button { selectedID = product.id } label: { row(product) }
                }
            }

            Button {
                guard let product = selected else { return }
                Task { await purchase.purchase(product) }
            } label: {
                Text(hasFreeTrial(selected) ? "Start Free Trial" : "Continue")
            }
            .disabled(purchase.products.isEmpty)

            // Required disclosure — keep it truthful and specific.
            Text(disclosure(for: selected))
                .font(.footnote).foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button("Restore Purchases") { Task { await purchase.restore() } }
                Link("Terms of Use", destination: URL(string: "https://example.com/terms")!)
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.footnote)
        }
        .task { await purchase.loadProducts() }
    }

    /// title · length · price — straight from StoreKit, already localized.
    private func row(_ p: Product) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(p.displayName)                       // title
                Text(periodText(p)).font(.caption)        // length
            }
            Spacer()
            Text(p.displayPrice)                          // price, correct currency
        }
    }

    private func periodText(_ p: Product) -> String {
        guard let s = p.subscription else { return "One-time purchase" }
        let n = s.subscriptionPeriod.value
        switch s.subscriptionPeriod.unit {
        case .day:   return n == 1 ? "Billed daily"   : "Billed every \(n) days"
        case .week:  return n == 1 ? "Billed weekly"  : "Billed every \(n) weeks"
        case .month: return n == 1 ? "Billed monthly" : "Billed every \(n) months"
        case .year:  return n == 1 ? "Billed yearly"  : "Billed every \(n) years"
        @unknown default: return ""
        }
    }

    private func hasFreeTrial(_ p: Product?) -> Bool {
        p?.subscription?.introductoryOffer?.paymentMode == .freeTrial
    }

    private func disclosure(for p: Product?) -> String {
        guard let p, let s = p.subscription else {
            return "One-time purchase. No subscription."
        }
        let trial = hasFreeTrial(p)
            ? "\(s.introductoryOffer?.period.value ?? 0)-day free trial, then "
            : ""
        return trial + "\(p.displayPrice) \(periodText(p).lowercased()), auto-renews. "
             + "Cancel anytime in Settings at least 24 hours before the period ends."
    }
}
```

> **Prices:** always `product.displayPrice` — never a hardcoded string. It is
> already localized/currency-correct, and it can't drift from ASC.
>
> **Price per unit** (e.g. "≈ $3.00/month" on a quarterly plan) is a nice-to-have
> Apple mentions; compute it from `product.price`, don't hardcode.

---

## 4. Local testing config

`Products.storekit` (File → New → StoreKit Configuration; sync from ASC or hand-write),
then Edit Scheme → Run → Options → **StoreKit Configuration**.

```jsonc
// Test-only. This file NEVER creates real products — a tier here that is absent
// from App Store Connect will render locally and vanish in sandbox/production.
{
  "products": [
    { "productID": "app.example.pro.lifetime", "type": "NonConsumable", "displayPrice": "19.99" }
  ],
  "subscriptionGroups": [{
    "name": "Pro",
    "subscriptions": [
      { "productID": "app.example.pro.monthly",   "recurringSubscriptionPeriod": "P1M", "displayPrice": "3.99" },
      { "productID": "app.example.pro.quarterly", "recurringSubscriptionPeriod": "P3M", "displayPrice": "8.99" }
    ]
  }]
}
```

Verify in **sandbox** before believing any of it.

---

## 5. Pre-submit code audit

- [ ] `ProductID.all` == the product IDs in ASC (run `scripts/asc-iap-status.mjs`)
- [ ] `Transaction.updates` listener starts at launch
- [ ] Every verified transaction gets `finish()`
- [ ] Entitlement read from `currentEntitlements`
- [ ] Restore reachable from paywall **and** Settings
- [ ] Paywall renders only loaded products; no dead buttons
- [ ] Paywall shows title/length/price/trial/auto-renew + Terms + Privacy
- [ ] Prices come from `displayPrice`
