# PoE2 Crafting System Schema Design

## Overview

This document outlines the data model for the PoeProfit crafting system, which allows users to calculate expected profit from Path of Exile 2 crafting operations. The system tracks currency/item inputs, weighted outcome probabilities, and historical pricing to provide profit analysis.

## Design Principles

- **Exalted Orbs as Standard**: All costs displayed in exalted orbs (not chaos or divine)
- **No Multi-Step Initially**: Single operation crafts (one set of inputs → weighted outcomes)
- **Query-Based Items**: Item prices fetched on-demand via PoE Trade API queries (not stored)
- **Currency as Resources**: Currency items stored with periodic price syncs
- **Historical Tracking**: Price snapshots track profit trends over time
- **Community & Private**: Support both user-specific and shared community crafts

## Ash Domain: `PoeProfit.Crafting`

**Location**: `lib/poe_profit/crafting.ex`

### Resources

#### 1. Currency

Stores currency items with current market pricing in exalted orbs.

**Attributes:**
- `id` - UUID v7 primary key
- `poe_id` - String, unique identifier from PoE API
- `name` - String, display name (e.g., "Chaos Orb", "Divine Orb")
- `icon_url` - String, URL to currency icon image
- `league` - String, league context (e.g., "Rise of the Abyssal")
- `price_in_exalted` - Decimal, current market price in exalted orbs
- `last_price_update` - DateTime (utc_datetime_usec), when price was last synced
- `created_at` - DateTime
- `updated_at` - DateTime

**Relationships:**
- `has_many :craft_currency_inputs, CraftCurrencyInput`

**Identities:**
- `[:poe_id, :league]` - Same currency differs by league

**Actions:**
- `create` with `upsert?` enabled for periodic API sync

**Data Source**: PoeScout API (`PoeScout.get_currency_items/2`, `PoeScout.get_currency_by_id/3`)

---

#### 2. Craft

Main craft configuration representing a crafting operation.

**Attributes:**
- `id` - UUID v7 primary key
- `name` - String, user-facing craft name (e.g., "Budget Life/Res Helmet")
- `description` - Text, detailed explanation of craft strategy
- `league` - String, league this craft applies to
- `is_public` - Boolean, whether craft is shared with community
- `base_item_query` - Map/JSONB, stores PoE Trade API search parameters for base item
- `created_at` - DateTime
- `updated_at` - DateTime

**Relationships:**
- `belongs_to :user, PoeProfit.Accounts.User` (nullable for community crafts)
- `has_many :craft_currency_inputs, CraftCurrencyInput`
- `has_many :craft_item_inputs, CraftItemInput`
- `has_many :craft_outcomes, CraftOutcome`
- `has_many :price_snapshots, CraftPriceSnapshot`

**Policies:**
- Users can create/read/update/delete their own crafts
- Users can read public crafts (is_public = true)
- Cannot modify crafts owned by other users

**Code Interface:**
- `list_crafts/1` - List crafts (with filters for user/public)
- `get_craft/1` - Get single craft by ID
- `create_craft/1` - Create new craft
- `update_craft/2` - Update existing craft
- `delete_craft/1` - Delete craft

---

#### 3. CraftCurrencyInput

Currency consumed as input for a craft.

**Attributes:**
- `id` - UUID v7 primary key
- `quantity` - Integer, number of currency items required
- `created_at` - DateTime
- `updated_at` - DateTime

**Relationships:**
- `belongs_to :craft, Craft` (required)
- `belongs_to :currency, Currency` (required)

**Example**: 5x Chaos Orbs + 1x Exalted Orb for a craft

---

#### 4. CraftItemInput

Non-currency items consumed as input (e.g., scarabs, essences, fragments).

**Attributes:**
- `id` - UUID v7 primary key
- `item_query` - Map/JSONB, PoE Trade API search parameters to find this item
- `quantity` - Integer, number of items required
- `description` - String, user-friendly name (e.g., "Deafening Essence of Greed")
- `created_at` - DateTime
- `updated_at` - DateTime

**Relationships:**
- `belongs_to :craft, Craft` (required)

**Note**: Item prices fetched on-demand using `item_query` when calculating profit.

---

#### 5. CraftOutcome

Possible weighted outcome from performing the craft.

**Attributes:**
- `id` - UUID v7 primary key
- `probability` - Decimal (0-100), percentage chance of this outcome occurring
- `outcome_item_query` - Map/JSONB, PoE Trade API search parameters for resulting item
- `description` - String, user-friendly outcome name (e.g., "Hit T1 Life + T1 Fire Res")
- `created_at` - DateTime
- `updated_at` - DateTime

**Relationships:**
- `belongs_to :craft, Craft` (required)

**Validation**: Sum of probabilities for a craft's outcomes should equal 100%

**Example**:
- 5% chance: "Perfect rolls (T1 life, T1 res, T1 res)" → 50 exalted value
- 25% chance: "Good rolls (T1-T2 mix)" → 10 exalted value
- 70% chance: "Brick/vendor" → 0 exalted value

---

#### 6. CraftPriceSnapshot

Historical record of craft profitability at a point in time.

**Attributes:**
- `id` - UUID v7 primary key
- `snapshot_at` - DateTime, when snapshot was taken
- `total_input_cost_exalted` - Decimal, total cost of all inputs in exalted
- `expected_output_value_exalted` - Decimal, probability-weighted expected value
- `expected_profit_exalted` - Decimal, expected output - total input cost
- `price_breakdown` - Map/JSONB, detailed breakdown of costs:
  ```json
  {
    "base_item": {"query": {...}, "price": 2.5},
    "currencies": [
      {"name": "Chaos Orb", "quantity": 5, "price_per": 0.01, "total": 0.05}
    ],
    "items": [
      {"description": "Essence", "query": {...}, "quantity": 1, "price_per": 1.2, "total": 1.2}
    ],
    "outcomes": [
      {"description": "Perfect", "probability": 5, "value": 50, "weighted": 2.5}
    ]
  }
  ```
- `created_at` - DateTime

**Relationships:**
- `belongs_to :craft, Craft` (required)

**Purpose**: Track profit trends over time as market prices fluctuate.

---

## Profit Calculation Logic

When calculating expected profit for a craft:

1. **Base Item Cost**:
   - Execute `base_item_query` against PoE Trade API
   - Get median/average price in exalted orbs

2. **Currency Input Costs**:
   - For each `CraftCurrencyInput`: `quantity * currency.price_in_exalted`
   - Sum all currency costs

3. **Item Input Costs**:
   - For each `CraftItemInput`: Execute `item_query` against PoE Trade API
   - Get price × quantity for each item
   - Sum all item costs

4. **Expected Output Value**:
   - For each `CraftOutcome`: Execute `outcome_item_query` to get value
   - Weighted average: `sum(outcome.probability * outcome_price) / 100`

5. **Expected Profit**:
   ```
   Expected Profit = Expected Output Value - (Base Cost + Currency Costs + Item Costs)
   ```

**Implementation Module**: `PoeProfit.Crafting.ProfitCalculator`

---

## Implementation Roadmap

### Phase 1: Core Schema
1. Create `lib/poe_profit/crafting.ex` domain
2. Create resource files for all 6 resources
3. Generate migrations: `mix ash_postgres.generate_migrations`
4. Run migrations: `mix ash.setup`

### Phase 2: Currency Sync
1. Create `PoeProfit.Crafting.Jobs.SyncCurrencies` Oban job
2. Fetch currency prices from PoeScout API
3. Upsert to Currency resource with league context
4. Schedule periodic sync (every 15 minutes)

### Phase 3: Profit Calculator
1. Create `PoeProfit.Crafting.ProfitCalculator` service module
2. Implement query execution against PoE Trade API
3. Implement weighted probability calculation
4. Handle caching/rate limiting for API calls

### Phase 4: LiveView UI
1. Create `PoeProfitWeb.CraftLive.Index` - List crafts
2. Create `PoeProfitWeb.CraftLive.Show` - View craft with profit
3. Create `PoeProfitWeb.CraftLive.Form` - Build/edit craft
4. Components for adding inputs/outcomes
5. Real-time profit display

### Phase 5: Price Snapshots
1. Create `PoeProfit.Crafting.Jobs.SnapshotPrices` Oban job
2. Calculate profit for all active crafts
3. Store snapshot records
4. Schedule periodic snapshots (daily/hourly)
5. Display profit trends in UI (charts)

---

## API Integration Notes

### PoeScout API (Currency Pricing)

**Primary Endpoint**: `PoeScout.get_currency_items(category, league: league)`
- Returns paginated currency items with `chaos_equivalent` pricing
- Categories available via `PoeScout.get_categories()` → `currency_categories`
- Convert chaos prices to exalted using league divine/chaos rates

**League Context**:
```elixir
# Get leagues with exchange rates
{:ok, leagues} = PoeScout.get_leagues()
# Returns: [%{value: "Rise of the Abyssal", divine_price: 150.5, chaos_divine_price: 0.0066}]

# Calculate exalted price from chaos
exalted_price_in_chaos = 100  # Example: exalted orbs are 100 chaos
chaos_price = currency_item.chaos_equivalent
exalted_price = chaos_price / exalted_price_in_chaos
```

### PoE Trade API (Item Pricing)

**Search Flow**:
```elixir
# 1. Execute search query
{:ok, %{"id" => query_id, "result" => item_ids}} =
  PoeApi.Trade.search(%{query: item_query, sort: %{price: "asc"}})

# 2. Fetch item details
{:ok, %{"result" => items}} =
  PoeApi.Trade.get_items(Enum.take(item_ids, 10), query_id)

# 3. Extract pricing
prices = Enum.map(items, fn item ->
  item["listing"]["price"]["amount"] * convert_to_exalted(item["listing"]["price"]["currency"])
end)

median_price = calculate_median(prices)
```

**Query Storage**: Store full query maps in `item_query` fields for reproducibility.

---

## Future Enhancements (Out of Scope for MVP)

- Multi-step crafts (sequential operations)
- Craft sharing/import via shareable links
- Craft templates/categories
- ROI calculator (include opportunity cost)
- Market volatility indicators
- Craft success/failure tracking (user-reported outcomes)
- Integration with crafting bench costs
- Support for influenced/synthesized bases
- Bulk crafting profit analysis (crafting N items)

---

## Database Conventions

Following existing PoeProfit patterns:

- **Primary Keys**: UUID v7 (time-ordered) for all resources
- **Timestamps**: `created_at`/`updated_at` with `utc_datetime_usec`
- **Table Names**: Plural snake_case (`currencies`, `crafts`, `craft_currency_inputs`, etc.)
- **Foreign Keys**: Named constraints (`crafts_user_id_fkey`)
- **JSONB Storage**: Use `map` attribute type for query/breakdown storage
- **Migration Generator**: `mix ash_postgres.generate_migrations --name add_crafting`

---

## Authorization & Policies

Using Ash policies for row-level security:

**Craft Policies**:
```elixir
policies do
  # Users can manage their own crafts
  policy action_type(:read) do
    authorize_if expr(user_id == ^actor(:id))
    authorize_if expr(is_public == true)
  end

  policy action_type([:create, :update, :destroy]) do
    authorize_if expr(user_id == ^actor(:id))
  end
end
```

**Public Crafts**: Readable by all, editable only by owner.
