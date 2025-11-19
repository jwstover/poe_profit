# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Project

PoeProfit is a Phoenix web application for Path of Exile (PoE) item trading and profit analysis. It integrates with the Path of Exile Trade API to search and fetch item data, helping users find profitable trading opportunities.

## Key Technologies

- **Phoenix 1.8.1** with LiveView for real-time web UI
- **Ash Framework 3.0** for domain-driven design and resource management
- **AshAuthentication** for user authentication (with token-based auth, magic links)
- **AshPostgres** as the data layer with Ecto
- **Oban** for background job processing
- **Req** library for HTTP requests (preferred over HTTPoison/Tesla)
- **Tailwind CSS v4** for styling (no config file, uses @import syntax)
- **esbuild** for JavaScript bundling

## Common Commands

### Setup
```bash
mix setup                    # Install deps, setup DB, assets, and seed data
mix ash.setup                # Setup Ash resources and database
mix deps.get                 # Install dependencies only
```

### Development
```bash
mix phx.server              # Start Phoenix server (port 4000)
iex -S mix phx.server       # Start Phoenix in IEx console
```

### Testing
```bash
mix test                    # Run all tests (runs ash.setup first)
mix test path/to/test.exs   # Run specific test file
mix test --failed           # Re-run previously failed tests
```

### Assets
```bash
mix assets.setup            # Install Tailwind and esbuild
mix assets.build            # Compile assets (Tailwind + esbuild)
mix assets.deploy           # Minify and digest for production
```

### Code Quality
```bash
mix precommit               # Pre-commit checks: compile with warnings-as-errors, unlock unused deps, format, test
mix format                  # Format code
mix compile --warnings-as-errors
```

### Development Tools (dev environment only)
```bash
# Available at /dev routes:
/dev/dashboard              # LiveDashboard
/dev/mailbox                # Swoosh email preview
/oban                       # Oban dashboard
/admin                      # AshAdmin interface
```

## Architecture

### Domain Structure

The application uses Ash Framework's domain-driven design with two main domains:

- **PoeProfit.Accounts** (`lib/poe_profit/accounts.ex`): User management and authentication
  - Resources: `User`, `Token`
  - Uses AshAuthentication with token-based auth, magic links, password resets

- **PoeProfit.ItemStats** (`lib/poe_profit/item_stats.ex`): PoE item statistics and types
  - Resources: `Stat`, `StatType`
  - Fetches and stores item stat metadata from PoE API

### Web Layer (PoeProfitWeb)

Located in `lib/poe_profit_web/`:

- **Router** (`router.ex`):
  - Authenticated routes use `ash_authentication_live_session` with `LiveUserAuth` hooks
  - Main routes: `/` (HomeLive), `/items` (ItemsLive)
  - Auth routes handled by AshAuthentication Phoenix integration

- **LiveViews**:
  - `HomeLive`: Landing page
  - `ItemsLive`: Item search and listing interface
  - Uses `FilterParamsHelper` for URL query param persistence

- **Components**:
  - `CoreComponents`: Standard Phoenix components (forms, inputs, icons, etc.)
  - `FiltersComponent`: Dynamic filter UI generation from PoE API filter structure
    - Generates nested form inputs matching API structure: `filters[group_id][filters][filter_id][option]`
    - Supports minMax ranges, dropdowns with options, and text inputs
    - Includes typeahead select for large option lists
  - `Layouts`: App-wide layouts (requires `current_scope` assign in authenticated routes)

### PoE API Integration

- **PoeProfit.PoeApi.Trade** (`lib/poe_profit/poe_api/trade.ex`):
  - `search/1`: Search for items on PoE trade
  - `get_items/3`: Fetch specific items by IDs from search results
  - Base URL: `https://www.pathofexile.com/api/trade2`
  - Uses Req library for HTTP requests

### Frontend

- **JavaScript** (`assets/js/`):
  - `app.js`: Main entry point
  - `hooks/`: LiveView hooks for client-side behaviors
  - TypeScript config available

- **CSS** (`assets/css/`):
  - Uses Tailwind CSS v4 with new @import syntax (no tailwind.config.js)
  - Custom CSS in app.css

### Authentication Flow

- Uses AshAuthentication with multiple strategies
- Token storage in database (all tokens stored)
- Supports: password auth, magic links, email confirmation
- LiveView routes protected by `LiveUserAuth` on_mount hooks
- Three auth states: `:live_user_required`, `:live_user_optional`, `:live_no_user`

### Background Jobs

- Oban configured with basic engine and PostgreSQL notifier
- AshOban integration for Ash resource background processing
- Queue: `default` with 10 workers

## Important Project-Specific Guidelines

Refer to `AGENTS.md` for comprehensive Phoenix, Elixir, LiveView, and UI/UX guidelines including:

- Phoenix v1.8 specific patterns (Layouts.app, flash components, core_components usage)
- Tailwind CSS v4 import syntax and styling best practices
- LiveView streams for collections, form handling, testing patterns
- Elixir-specific gotchas (no index access on lists, immutable rebinding, no else-if)
- HEEx template syntax (curly braces, class lists, interpolation rules)
- Always use `Req` library for HTTP requests

### Key Conventions

- **Always run `mix precommit`** before completing changes
- Use Ash resource actions for data operations (defined in domain modules)
- Filter UI is auto-generated from PoE API structure via `FiltersComponent`
- Query params persist in URL via `FilterParamsHelper` for shareable filtered views
- Authentication required for main app routes (HomeLive, ItemsLive)
