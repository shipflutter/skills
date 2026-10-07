# EP01 Skill Store User Stories

## EP01.US001 Browse Premium Skills

As a user, I want to browse a premium skill catalog so that I can discover paid skills that improve my AI workflow.

### Acceptance Criteria

- Shows featured premium skills with title, category, summary, price, and included assets.
- Supports category filtering without page reload.
- Highlights which skills are premium-only.

## EP01.US002 Inspect Skill Value

As a user, I want to inspect what a premium skill includes so that I can decide whether it is worth buying.

### Acceptance Criteria

- Selecting a skill updates the detail panel.
- Detail panel shows outcomes, bundle contents, and refund/support note.
- Primary CTA starts checkout for the selected skill.

## EP01.US003 Start SePay Checkout

As a buyer, I want to start checkout and receive bank transfer instructions so that I can pay with SePay-supported transfer flow.

### Acceptance Criteria

- Checkout displays exact amount, order code, transfer content, expiration, and bank account placeholder.
- Buyer email is captured before or during checkout.
- Browser never stores SePay secrets or private API keys.

## EP01.US003A Store Product Selection Page

As a buyer, I want a dedicated store page with product cards, filters, search, and pricing so that I can choose the right premium skill before checkout.

### Acceptance Criteria

- Store page is available at `public/store.html`.
- Store page shows product cards with category, summary, outcomes, included assets, price, and CTA.
- Users can filter by category, search by product terms, and sort by price.
- Users can start checkout directly from a product card.
- Store page reuses the same checkout modal and backend checkout session flow as the homepage.

## EP01.US004 Confirm Payment

As a buyer, I want the page to show payment confirmation after bank transfer so that I know when my skill is unlocked.

### Acceptance Criteria

- Pending state explains that confirmation happens through webhook reconciliation.
- Paid state shows access/unlock confirmation.
- Duplicate webhook events do not duplicate entitlements in backend design.

## EP01.US005 Handle Payment Exceptions

As an operator, I want clear order/payment states so that support can handle wrong amount, missing code, or expired orders.

### Acceptance Criteria

- Technical design includes `pending`, `paid`, `expired`, `needs_review`, and `failed` states.
- Technical design documents manual reconciliation endpoint.
- UI includes a support contact area for payment issues.
