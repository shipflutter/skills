# EP01 Skill Store Technical Design

## Overview

Skill Store is a static-first premium marketplace prototype with a future backend integration for SePay payments. The frontend owns catalog presentation and checkout UI states. The backend owns order creation, SePay webhook verification, transaction matching, and entitlement grants.

## Modules

- `public/index.html`: semantic page shell, catalog sections, checkout modal.
- `public/styles.css`: responsive visual system, bento grid, modal, motion states.
- `public/app.js`: catalog state, filters, detail rendering, checkout modal, mocked status transition.
- Future `api/checkout`: order session creation and order polling.
- Future `api/webhooks/sepay`: webhook receiver and reconciliation.

## Entities

### Skill

- `id`: stable catalog id.
- `title`: display name.
- `category`: filter group.
- `summary`: short promise.
- `price`: integer VND amount.
- `includes`: list of deliverables.
- `outcomes`: list of buyer outcomes.
- `premiumOnly`: boolean.

### Order

- `orderCode`: unique transfer code embedded in bank transfer content.
- `skillId`: purchased skill id.
- `buyerEmail`: entitlement recipient.
- `amount`: expected VND amount.
- `status`: `pending`, `paid`, `expired`, `needs_review`, `failed`.
- `expiresAt`: transfer deadline.

### PaymentTransaction

- `sepayTransactionId`: provider transaction id when available.
- `amount`: received amount.
- `content`: bank transfer description.
- `rawPayload`: immutable webhook payload.
- `receivedAt`: webhook timestamp.

### Entitlement

- `buyerEmail` or `userId`.
- `skillId`.
- `orderCode`.
- `status`: `active`, `revoked`.

## Checkout Flow

1. User chooses skill and submits email.
2. Frontend calls `POST /api/checkout/sessions`.
3. Backend creates `Order(status=pending)` and returns transfer instructions.
4. Frontend shows SePay payment panel and polls `GET /api/orders/:orderCode`.
5. SePay sends webhook to `POST /api/webhooks/sepay` after bank transaction.
6. Backend authenticates webhook, stores raw payload, extracts amount/content, matches order code.
7. If exact match, backend marks order paid and creates entitlement idempotently.
8. Polling response changes to `paid`; frontend shows unlock confirmation.

## Webhook Rules

- Reject unauthenticated webhook requests.
- Store raw payload before processing for audit.
- Match order by exact transfer code in transaction content.
- Require received amount to equal expected order amount.
- Mark wrong amount or ambiguous content as `needs_review`.
- Treat duplicate transaction ids/order paid events as successful no-ops.
- Do not expose webhook secrets or bank API credentials to the frontend.

## UI States

- Catalog empty state if filters have no result.
- Selected skill detail state.
- Checkout modal pending state.
- Checkout modal mock paid state.
- Future expired/review state.

## Security Notes

- Frontend prototype uses mock payment state only.
- Production must create order codes server-side.
- Production must validate SePay webhook authentication according to the configured SePay dashboard method.
- Production should rate-limit checkout creation and webhook endpoints.
- Production should avoid trusting client-provided price values.

## Test Strategy

- Unit tests for catalog filters and currency formatting.
- Unit tests for backend order matching and idempotent entitlement grant.
- Integration tests for SePay webhook valid, invalid auth, wrong amount, duplicate transaction, and missing order code.
- E2E test for browse -> checkout -> webhook paid -> unlock.
