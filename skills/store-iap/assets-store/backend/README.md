# Assets Store Backend

Node.js TypeScript API for local Assets Store testing. It uses `data/db.json` as a dummy file database through a service layer, so the API can be replaced by a real database later without changing route contracts.

## Run

```bash
cd assets-store/backend
npm install
npm run seed
npm run dev
```

API base URL: `http://localhost:5174`

Demo account:

- Email: `buyer@example.com`
- Password: `password123`

## Endpoints

- `GET /health`
- `POST /api/auth/sign-up`
- `POST /api/auth/sign-in`
- `GET /api/auth/me`
- `GET /api/skills`
- `POST /api/checkout/sessions`
- `GET /api/orders/:orderCode`
- `POST /api/webhooks/sepay`

## Mock SePay Webhook

After creating checkout, send:

```bash
curl -X POST http://localhost:5174/api/webhooks/sepay \
  -H 'content-type: application/json' \
  -d '{"transactionId":"demo-tx-1","amountVnd":899000,"transferContent":"SKILL-YYYYMMDD-ABC123"}'
```

Use the exact `order.orderCode` and `order.amountVnd` returned by checkout.
