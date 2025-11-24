defmodule PoeProfit.PoeScout do
  @moduledoc """
  Client for fetching data from the POE2Scout API.
  Provides access to item prices, categories, leagues, and currency exchange data.

  POE2Scout is a third-party service that aggregates Path of Exile 2 market data
  and currency exchange information.
  """

  require Logger

  @base_url "https://poe2scout.com/api"

  # ╭──────────────────────────────────────────────────────────────────────────────╮
  # │                               ITEMS ENDPOINTS                                │
  # ╰──────────────────────────────────────────────────────────────────────────────╯

  @doc """
  Get all item categories (unique and currency).

  Returns a map with `:unique_categories` and `:currency_categories` keys.

  ## Examples

      iex> PoeProfit.PoeScout.get_categories()
      {:ok, %{unique_categories: [...], currency_categories: [...]}}
  """
  @spec get_categories() :: {:ok, map()} | {:error, term()}
  def get_categories do
    request(:get, "/items/categories")
  end

  @doc """
  Get unique items by category with optional filtering and pagination.

  ## Options

    * `:reference_currency` - Reference currency for pricing (default: "exalted")
    * `:search` - Search term to filter items (default: "")
    * `:page` - Page number for pagination (default: 1)
    * `:per_page` - Items per page (default: 25)
    * `:league` - League name (default: "Standard")

  ## Examples

      iex> PoeProfit.PoeScout.get_unique_items("weapons", league: "Settlers", page: 1)
      {:ok, %{current_page: 1, pages: 5, total: 120, items: [...]}}
  """
  @spec get_unique_items(String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get_unique_items(category, opts \\ []) do
    query_params =
      build_query_params(%{
        referenceCurrency: Keyword.get(opts, :reference_currency, "exalted"),
        search: Keyword.get(opts, :search, ""),
        page: Keyword.get(opts, :page, 1),
        perPage: Keyword.get(opts, :per_page, 25),
        league: Keyword.get(opts, :league, "Standard")
      })

    request(:get, "/items/unique/#{category}?#{query_params}")
  end

  @doc """
  Get currency items by category with optional filtering and pagination.

  ## Options

    * `:reference_currency` - Reference currency for pricing (default: "exalted")
    * `:search` - Search term to filter items (default: "")
    * `:page` - Page number for pagination (default: 1)
    * `:per_page` - Items per page (default: 25)
    * `:league` - League name (default: "Standard")

  ## Examples

      iex> PoeProfit.PoeScout.get_currency_items("fragments", league: "Settlers")
      {:ok, %{current_page: 1, pages: 2, total: 45, items: [...]}}
  """
  @spec get_currency_items(String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get_currency_items(category, opts \\ []) do
    query_params =
      build_query_params(%{
        referenceCurrency: Keyword.get(opts, :reference_currency, "exalted"),
        search: Keyword.get(opts, :search, ""),
        page: Keyword.get(opts, :page, 1),
        perPage: Keyword.get(opts, :per_page, 25),
        league: Keyword.get(opts, :league, "Standard")
      })

    request(:get, "/items/currency/#{category}?#{query_params}")
  end

  @doc """
  Get available filter configurations for items.

  ## Examples

      iex> PoeProfit.PoeScout.get_filters()
      {:ok, %{...}}
  """
  @spec get_filters() :: {:ok, map()} | {:error, term()}
  def get_filters do
    request(:get, "/items/filters")
  end

  @doc """
  Get all items for a specific league.

  ## Examples

      iex> PoeProfit.PoeScout.get_all_items("Settlers")
      {:ok, [...]}
  """
  @spec get_all_items(String.t()) :: {:ok, list()} | {:error, term()}
  def get_all_items(league) do
    query_params = build_query_params(%{league: league})
    request(:get, "/items?#{query_params}")
  end

  @doc """
  Get price history for a specific item.

  ## Options

    * `:start` - Start timestamp for history
    * `:end` - End timestamp for history

  ## Examples

      iex> PoeProfit.PoeScout.get_item_history(123, "Settlers", 100)
      {:ok, [...]}
  """
  @spec get_item_history(integer(), String.t(), integer(), keyword()) ::
          {:ok, list()} | {:error, term()}
  def get_item_history(item_id, league, log_count, opts \\ []) do
    query_params =
      build_query_params(%{
        league: league,
        logCount: log_count,
        start: Keyword.get(opts, :start),
        end: Keyword.get(opts, :end)
      })

    request(:get, "/items/#{item_id}/history?#{query_params}")
  end

  @doc """
  Get featured items information for landing page display.

  ## Examples

      iex> PoeProfit.PoeScout.get_landing_splash_info()
      {:ok, %{...}}
  """
  @spec get_landing_splash_info() :: {:ok, map()} | {:error, term()}
  def get_landing_splash_info do
    request(:get, "/items/landingSplashInfo")
  end

  @doc """
  Get a specific currency item by its API ID.

  ## Examples

      iex> PoeProfit.PoeScout.get_currency_by_id("chaos-orb", "Settlers")
      {:ok, %{...}}
  """
  @spec get_currency_by_id(String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def get_currency_by_id(api_id, league) do
    query_params = build_query_params(%{league: league})
    request(:get, "/items/currencyById/#{api_id}?#{query_params}")
  end

  # ╭──────────────────────────────────────────────────────────────────────────────╮
  # │                              Leagues Endpoints                               │
  # ╰──────────────────────────────────────────────────────────────────────────────╯

  @doc """
  Get all available leagues with divine and chaos prices.

  Returns a list of leagues with their currency pricing information.

  ## Examples

      iex> PoeProfit.PoeScout.get_leagues()
      {:ok, [%{value: "Settlers", divine_price: 150.5, chaos_divine_price: 0.0066}, ...]}
  """
  @spec get_leagues() :: {:ok, list()} | {:error, term()}
  def get_leagues do
    request(:get, "/leagues")
  end

  # ╭──────────────────────────────────────────────────────────────────────────────╮
  # │                         Currency Exchange Endpoints                          │
  # ╰──────────────────────────────────────────────────────────────────────────────╯

  @doc """
  Get the current currency exchange snapshot for a league.

  Returns snapshot data including epoch, volume, and market cap.

  ## Examples

      iex> PoeProfit.PoeScout.get_currency_snapshot("Settlers")
      {:ok, %{epoch: 1234567890, volume: "1500000", market_cap: "5000000"}}
  """
  @spec get_currency_snapshot(String.t()) :: {:ok, map()} | {:error, term()}
  def get_currency_snapshot(league) do
    query_params = build_query_params(%{league: league})
    request(:get, "/currencyExchangeSnapshot?#{query_params}")
  end

  @doc """
  Get historical currency exchange snapshots for a league.

  ## Options

    * `:start` - Start timestamp for history
    * `:end` - End timestamp for history

  ## Examples

      iex> PoeProfit.PoeScout.get_snapshot_history("Settlers", 50)
      {:ok, [...]}
  """
  @spec get_snapshot_history(String.t(), integer(), keyword()) ::
          {:ok, list()} | {:error, term()}
  def get_snapshot_history(league, limit, opts \\ []) do
    query_params =
      build_query_params(%{
        league: league,
        limit: limit,
        start: Keyword.get(opts, :start),
        end: Keyword.get(opts, :end)
      })

    request(:get, "/currencyExchange/SnapshotHistory?#{query_params}")
  end

  @doc """
  Get currency trading pairs in the current snapshot for a league.

  Returns a list of currency pairs with trading volume and price data.

  ## Examples

      iex> PoeProfit.PoeScout.get_snapshot_pairs("Settlers")
      {:ok, [...]}
  """
  @spec get_snapshot_pairs(String.t()) :: {:ok, list()} | {:error, term()}
  def get_snapshot_pairs(league) do
    query_params = build_query_params(%{league: league})
    request(:get, "/currencyExchange/SnapshotPairs?#{query_params}")
  end

  @doc """
  Get historical trading data for a specific currency pair.

  ## Options

    * `:start` - Start timestamp for history
    * `:end` - End timestamp for history

  ## Examples

      iex> PoeProfit.PoeScout.get_pair_history("Settlers", 1, 2, 100)
      {:ok, [...]}
  """
  @spec get_pair_history(String.t(), integer(), integer(), integer(), keyword()) ::
          {:ok, list()} | {:error, term()}
  def get_pair_history(league, currency_one_id, currency_two_id, limit, opts \\ []) do
    query_params =
      build_query_params(%{
        league: league,
        currencyOneId: currency_one_id,
        currencyTwoId: currency_two_id,
        limit: limit,
        start: Keyword.get(opts, :start),
        end: Keyword.get(opts, :end)
      })

    request(:get, "/currencyExchange/PairHistory?#{query_params}")
  end

  # ╭──────────────────────────────────────────────────────────────────────────────╮
  # │                   ========================================                   │
  # │                           Private Helper Functions                           │
  # │                   ========================================                   │
  # ╰──────────────────────────────────────────────────────────────────────────────╯

  defp request(method, path) do
    url = @base_url <> path

    case Req.request(method: method, url: url) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        Logger.error("POE2Scout API request failed: #{status} - #{inspect(body)}")
        {:error, {:http_error, status, body}}

      {:error, reason} = error ->
        Logger.error("POE2Scout API request failed: #{inspect(reason)}")
        error
    end
  end

  defp build_query_params(params) do
    params
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> URI.encode_query()
  end
end
