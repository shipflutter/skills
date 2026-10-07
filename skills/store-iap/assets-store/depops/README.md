# Assets Store Deployment Guide

This folder documents how to deploy the Assets Store static UI and Node.js TypeScript backend.

## Local Build

From repository root:

```bash
cd assets-store
./build.sh
```

The build output is created at `assets-store/dist-deploy/`.

## Runtime Layout

```text
dist-deploy/
├── client/              # Static HTML/CSS/JS storefront
└── backend/
    ├── dist/            # Compiled Node.js API
    ├── data/db.json     # Local dummy database for test deployment
    ├── package.json
    └── package-lock.json
```

## Deploy Static UI

Any static hosting can serve `dist-deploy/client`:

- Nginx
- Caddy
- Cloudflare Pages
- Netlify
- Vercel static output

For the current prototype, `client/app.js` calls `http://localhost:5174`. Before production deploy, replace `apiBaseUrl` with the deployed API origin or inject it through a small runtime config file.

## Deploy Backend

On a VM or container:

```bash
cd dist-deploy/backend
npm ci --omit=dev
PORT=5174 npm start
```

Recommended production process manager:

```bash
pm2 start dist/server.js --name assets-store-api --time
pm2 save
```

## Environment Notes

- `PORT`: backend HTTP port, default `5174`.
- SePay webhook secret/auth config is not implemented yet in the dummy backend.
- `data/db.json` is only for local/demo deployment. Replace it with PostgreSQL before handling real users or payments.

## Health Check

```bash
curl http://localhost:5174/health
```

Expected response:

```json
{"ok":true,"service":"skill-store-backend"}
```

## Manual Smoke Test

```bash
curl http://localhost:5174/api/skills

curl -X POST http://localhost:5174/api/auth/sign-in \
  -H 'content-type: application/json' \
  -d '{"email":"buyer@example.com","password":"password123"}'
```

Use the returned token to create checkout sessions with `Authorization: Bearer <token>`.
