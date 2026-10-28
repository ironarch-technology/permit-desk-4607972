# Permit Desk

Orchestration service behind the Mountport building permit portal. It takes an application
from the public portal, walks it through zoning, plan review, corrections, fee assessment and
payment, and issues the permit at the end.

Development Services owns this. The four systems it talks to belong to other departments.

## What's in here

| Path | What it is |
|---|---|
| `permit_desk/` | Rails app. REST for the portal pages, GraphQL for everything the browser needs, Sidekiq for the orchestration. |
| `mocks/` | Stand-ins for the four city services, so you can work without the real ones. |
| `docker-compose.yml` | The whole thing, locally. |

## Running it

```
docker compose up --build
```

First run takes a few minutes while the gems install. After that the portal is on
<http://localhost:3000> and the API answers on the same host.

Sign in with one of the seeded accounts:

| Email | Password | Role |
|---|---|---|
| `rosa.linden@example.com` | `harborlight` | Applicant |
| `dmitri.vale@example.com` | `harborlight` | Applicant |
| `counter@mountport.gov` | `frontdesk` | Counter staff |

The seed data includes eight Mountport parcels. The address field on the first step of the
application only matches those.

## Watching an application go through

The mock services are on timers, so a full run takes about a minute of wall clock:

1. Create a draft and submit it. Zoning picks it up within a few seconds.
2. Zoning clears it and it lands in plan review.
3. Plan review comes back with two corrections on the first cycle. Answer both.
4. Second cycle approves it, cashiering quotes the fees, and the application sits at
   fees due.
5. Pay on the application page. Cashiering confirms over the webhook and the permit is issued.
6. Inspections open up once it's issued.

`640 Quarry Bend` is the parcel the county layer disagrees with. Submit against that one if
you want to see a zoning hold.

## Service topology

| Service | Port | Notes |
|---|---|---|
| `app` | 3000 | Rails, Puma. Portal pages and `/graphql`. |
| `worker` | - | Sidekiq. Queues are `default` and `orchestration`. |
| `db` | 5432 | Postgres 16. |
| `redis` | 6379 | Sidekiq only. |
| `zoning` | 4100 | Async. Settles about six seconds after submit, then calls `/hooks/zoning`. |
| `review` | 4200 | Async. Decides after about twelve seconds. Polled, not pushed. |
| `scheduling` | 4300 | Slot search is synchronous. Returns 409 when a slot goes while you're looking at it. |
| `cashiering` | 4400 | Quote is synchronous. Capture confirms over `/hooks/cashiering`. |

The static assets are served straight out of `permit_desk/public` by the `web` container on
port 8088.

## API

REST, under `/portal`, is what the server-rendered pages post to. GraphQL is at `/graphql` and
wants a signed-in session cookie.

```graphql
query {
  myApplications {
    reference
    state
    parcel { address district }
    feeQuote { totalCents expiresAt }
  }
}
```

```graphql
mutation {
  initiatePayment(reference: "MP-2026-1A2B3C4D", amountCents: 76500, quoteReference: "fq-9d10ff21") {
    captureReference
    errors
  }
}
```

Webhooks:

- `POST /hooks/zoning` with `handle`, `result`, `detail`
- `POST /hooks/cashiering` with `reference`, `capture_reference`, `amount_cents`, `status`

## Tests

```
docker compose exec app bundle exec rspec
```

There's a console too:

```
docker compose exec app bin/console
```

## Environment

`DATABASE_URL`, `REDIS_URL`, and the four `*_URL` variables for the city services are all set
in the compose file. `PORTAL_TOKEN_SECRET` signs the portal session cookie.
