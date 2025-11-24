# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PoeProfit is a Phoenix LiveView application for Path of Exile 2 (PoE2) item price tracking and trade analysis. It integrates with multiple PoE APIs to provide market insights and currency exchange data.

## Development Commands

### Setup & Installation
```bash
mix setup                    # Install deps, setup DB, build assets, seed data
```

### Running the Application
```bash
mix phx.server              # Start Phoenix server at localhost:4000
iex -S mix phx.server       # Start server with IEx console
```

### Testing
```bash
mix test                    # Run all tests
mix test test/path/to/test.exs  # Run specific test file
mix test --failed           # Run only previously failed tests
```

### Code Quality
```bash
mix precommit               # Run before committing: compile w/ warnings-as-errors, format, unlock unused deps, test
mix format                  # Format code
```

### Database
```bash
mix ash.setup               # Create DB, run migrations, seed (Ash convention)
mix ecto.reset              # Drop and recreate database
```

### Assets
```bash
mix assets.build            # Compile assets (Tailwind + esbuild)
mix assets.deploy           # Build and minify assets for production
```

### Development Tools
- `/dev/dashboard` - Phoenix LiveDashboard (metrics, processes, etc.)
- `/dev/mailbox` - Swoosh email preview
- `/oban` - Oban job dashboard
- `/admin` - Ash Admin interface

## Architecture

### Tech Stack
- **Framework**: Phoenix 1.8 + LiveView
- **Database**: PostgreSQL + Ecto
- **Data Layer**: Ash Framework 3.0 (resource-oriented framework)
- **Background Jobs**: Oban + AshOban
- **Authentication**: AshAuthentication with Phoenix integration
- **HTTP Client**: Req (preferred over HTTPoison/Tesla)
- **Assets**: Tailwind CSS v4 + esbuild

### Key Domains (Ash)
- `PoeProfit.ItemStats` - Item statistics and stat types from PoE API
- `PoeProfit.Accounts` - User authentication and management

### Core Modules

#### API Integration
- `PoeProfit.PoeScout` - Client for POE2Scout API (market data, currency exchange, leagues)
- `PoeProfit.PoeApi.Trade` - Path of Exile official trade API integration
- `PoeProfit.PoeApi.Filters` - Filter configuration from PoE API

#### LiveViews
- `PoeProfitWeb.HomeLive` - Landing page
- `PoeProfitWeb.ItemsLive` - Item search with complex filtering
- `PoeProfitWeb.FilterParamsHelper` - URL query param management for filters

#### Components
- `PoeProfitWeb.CoreComponents` - Base UI components (buttons, inputs, icons)
- `PoeProfitWeb.FiltersComponent` - Complex filter interface for item search
- `PoeProfitWeb.Layouts` - Layout templates (includes flash message handling)

### Authentication Flow
- Uses AshAuthentication with multiple strategies (password, magic link, confirmation)
- `PoeProfitWeb.LiveUserAuth` - Mount hooks for LiveView auth
- Routes are protected via `ash_authentication_live_session` blocks
- Auth overrides in `PoeProfitWeb.AuthOverrides`

### URL State Management
Filters in ItemsLive are persisted in URL query params via `FilterParamsHelper`:
- `handle_params/3` reads filters from URL
- `filter_change` event patches URL with new filter state
- Enables shareable search URLs and browser back/forward navigation

## Important Conventions

### Ash Framework
- Resources are defined with `use Ash.Resource`
- Domains (formerly "APIs") aggregate resources with `use Ash.Domain`
- Use code interfaces for querying: `ItemStats.list_stats()`
- Bulk operations via `Ash.bulk_create/3` for efficiency
- Typespecs aren't needed when `@impl true` is declared

### PoE API Integration
- POE2Scout API client (`PoeProfit.PoeScout`) provides market data
- Official PoE Trade API (`PoeProfit.PoeApi.Trade`) for live item searches
- Item mods contain special formatting: `[InternalName|Display Text]` - strip to display text
- Always use `Req` for HTTP requests (included dependency)

### LiveView Patterns
- All LiveViews use `ash_authentication_live_session` for auth context
- Must pass `current_scope` to `<Layouts.app>` wrapper
- Use streams for collections (`stream/3`, `stream_configure/2`) to avoid memory issues
- Reset streams with `reset: true` option for filtering/refreshing

### Asset Pipeline
- Tailwind v4 uses new `@import "tailwindcss"` syntax in `app.css`
- No `tailwind.config.js` needed - configured via CSS imports
- Vendor JS/CSS must be imported into `app.js`/`app.css` (no external `<script>` tags)
- Never write inline `<script>` tags in templates

### Code Style
- Use `cond` or `case` for multiple conditions (no `elsif`)
- HEEx interpolation: `{@var}` in attributes and bodies, `<%= block %>` for control flow
- List syntax for multiple classes: `class={["px-2", @flag && "py-5"]}`
- Never use `@apply` in CSS
- Elixir lists don't support index access (`list[i]`) - use `Enum.at/2`

## Testing Notes
- Use `LazyHTML` for test assertions (included)
- Reference element IDs in tests: `has_element?(view, "#my-form")`
- Test outcomes, not implementation details
- Add unique DOM IDs to key elements for testability
