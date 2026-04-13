# Elixir Phoenix Load Test

A Phoenix API application with a built-in Mix task for load testing using [k6](https://k6.io/) — no local k6 installation required, runs via Docker.

## Features

- JSON REST API (`/api/users`)
- Mix task that seeds test data, runs k6 via Docker, and cleans up automatically
- Cross-platform: works on macOS and Linux (handles Docker networking differences automatically)
- Configurable user count for seeding

## Requirements

- Elixir 1.15+
- Erlang/OTP 26+
- PostgreSQL
- Docker (for running k6)

## Setup

```bash
# Install dependencies and create the database
mix setup

# Run migrations
mix ecto.migrate
```

## Running the Server

```bash
mix phx.server
# or inside IEx
iex -S mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000).

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/users` | List users (paginated) |
| `GET` | `/api/users/:id` | Get a single user |

**Query params for `/api/users`:**
- `page` — page number (default: `1`)
- `per_page` — results per page (default: `20`)

## Load Testing

The load test seeds the database, runs a k6 script via Docker, then cleans up all seeded records.

```bash
# Start the server first
mix phx.server

# In a second terminal — seeds 10,000 users (default)
mix load_test

# Custom seed count
mix load_test 50000
```

### What the test does

- Ramps up to 50 virtual users over 50 seconds
- Each VU hits `GET /api/users` (random page) then `GET /api/users/:id`
- Thresholds: `p95 < 500ms`, error rate `< 1%`
- Reports custom metrics: `list_users_duration`, `show_user_duration`

### k6 script

The k6 script is at [`priv/k6/load_test.js`](./priv/k6/load_test.js) and can be customized to adjust stages, thresholds, or endpoints.

## Project Structure

```
lib/
  elixir_phoenix_load_test/
    accounts/user.ex          # User schema
    repo.ex                   # Ecto repo
  elixir_phoenix_load_test_web/
    controllers/
      user_controller.ex      # API endpoints
  mix/tasks/
    load_test.ex              # Mix load test task
priv/
  k6/
    load_test.js              # k6 test script
```

## License

MIT
