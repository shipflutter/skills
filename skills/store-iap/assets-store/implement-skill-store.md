# Skill Store Implementation Plan

## Feature Brief

Build a standalone premium skill marketplace where users can browse AI skills, compare free vs premium value, start checkout, pay via SePay bank transfer/QR flow, and unlock purchased skill packages after webhook confirmation.

The first implementation is a static HTML/CSS/JS prototype with a production-ready architecture plan. It must keep payment secrets out of the browser and model SePay as a server-side integration through checkout session creation plus webhook reconciliation.

## References

- UI direction: `gpt-tasteskill` premium AIDA structure, wide hero typography, dense bento, editorial product cards, strong CTAs, and motion-rich interactions.
- Payment direction: SePay integration page and SePay Webhooks quickstart.
- Local prototype: `public/index.html`, `public/styles.css`, `public/app.js`.
- Database/auth/payment architecture: `resources/technial-design/ep01-user-payment-database.md`.

## Goals

- Present premium skills as high-value digital products.
- Let users filter and inspect skill bundles.
- Start a checkout flow with a unique order code.
- Show a SePay-compatible transfer instruction/QR state.
- Poll/mock payment status in the static prototype.
- Document the real backend contract for webhook verification, order matching, and unlock fulfillment.

## Non-Goals For Prototype

- No real banking credentials in frontend JavaScript.
- No direct SePay secret/API key usage from browser.
- No real account system yet; unlock is represented as an order status state.
- No server implementation in this pass.

## Architecture Plan

### Frontend

- Static app in `skill-store/public/`.
- Components are authored with semantic HTML sections and vanilla JavaScript state.
- Data lives in `app.js` as seed catalog entries for now.
- Checkout modal renders order summary, bank transfer content, and payment status.
- User-facing states: browsing, filtering, detail selection, checkout pending, paid, failed/expired.

### Backend Contract

- `POST /api/checkout/sessions`
  - Input: `skillId`, `planId`, `buyerEmail`.
  - Creates order with status `pending` and unique transfer code such as `SKILL-20260611-AB12`.
  - Returns bank account, amount, transfer content, QR payload/image URL if available, and expiration time.
- `GET /api/orders/:orderCode`
  - Returns order status for frontend polling.
- `POST /api/webhooks/sepay`
  - Receives SePay webhook payload.
  - Verifies configured webhook authentication/signature according to SePay dashboard/docs.
  - Matches transaction by transfer content/order code and expected amount.
  - Marks order `paid` once, idempotently.
  - Grants premium skill access.
- `POST /api/orders/:orderCode/reconcile`
  - Optional admin/manual reconciliation for edge cases.

### Data Model

- `Skill`: id, slug, title, category, summary, level, tags, price, compareAtPrice, includes, outcomes, premiumOnly.
- `Order`: id, orderCode, buyerEmail, skillId, amount, status, expiresAt, createdAt, paidAt.
- `PaymentTransaction`: id, orderId, sepayTransactionId, bankAccount, amount, content, rawPayload, receivedAt.
- `Entitlement`: id, userId/email, skillId, orderId, grantedAt, status.

### SePay Flow

1. User selects a premium skill and enters email.
2. Backend creates an order and transfer code.
3. Frontend displays SePay bank transfer instructions/QR.
4. User transfers exact amount with exact content.
5. SePay sends webhook to backend.
6. Backend validates webhook, matches amount/content, records transaction, marks order paid.
7. Frontend polling detects paid state and shows unlock instructions.

## UI Plan

### Design Plan From `gpt-tasteskill`

```text
seed = len(prompt) % 97 = 42
hero = Artistic Asymmetry
font = Outfit-like system fallback
components = Bento grid, horizontal accordion, testimonial carousel
motion = scroll reveal, card hover physics
```

- AIDA: navigation, Attention hero, Interest skill grid, Desire premium workflow/payment section, Action checkout/footer.
- Hero H1 uses a wide container and clamp sizing to stay within 2-3 lines.
- Bento grid uses fixed responsive tracks with no intentional empty cells.
- Buttons have explicit dark/light contrast.
- No decorative meta-labels like `SECTION 01`.

## Task List Before Coding

- [x] Create feature package directory.
- [x] Create implementation plan.
- [x] Write user stories.
- [x] Write technical design.
- [x] Write ASCII screen layout.
- [x] Build static UI prototype with HTML/CSS/JS.
- [x] Design database architecture for users, auth sessions, checkout, SePay payments, and entitlements.
- [ ] Replace mocked checkout with real backend session API.
- [ ] Implement SePay webhook endpoint and verification.
- [ ] Add persistence for orders, transactions, and entitlements.
- [ ] Add authentication/account linking.
- [ ] Add test coverage for order matching, webhook idempotency, and amount validation.

## Acceptance Criteria

- Users can scan premium skills and understand pricing.
- Users can open checkout from any premium skill card.
- Checkout shows order code, amount, bank transfer content, and pending/paid states.
- Frontend contains no payment secrets.
- Technical design documents backend endpoints and webhook responsibilities.
- Prototype runs by opening `public/index.html` directly.

## Test Plan

- Manual browser test for responsive layout at mobile and desktop sizes.
- JavaScript smoke test by clicking filters, skill cards, checkout, mock paid, and modal close.
- Backend future tests:
  - Unit: order code generation, amount matching, content parsing.
  - Integration: SePay webhook valid/invalid/auth failure/idempotent duplicate.
  - E2E: checkout to paid unlock path.
