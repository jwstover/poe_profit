defmodule PoeProfit.PoeApi.Filters do
  @moduledoc """
  Client for fetching filter configurations from the Path of Exile Trade API.
  """

  require Logger

  @api_url "https://www.pathofexile.com/api/trade2/data/filters"

  @doc """
  Fetches filter configuration from the Path of Exile API.

  Returns `{:ok, filters}` on success or `{:error, reason}` on failure.

  ## Examples

      iex> PoeProfit.PoeApi.Filters.fetch()
      {:ok, %{"result" => [...]}}

      iex> PoeProfit.PoeApi.Filters.fetch()
      {:error, "Request failed: 500"}
  """
  def fetch do
    case Req.get(@api_url) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status}} ->
        Logger.error("PoE API returned status #{status}")
        {:error, "Request failed with status #{status}"}

      {:error, exception} ->
        Logger.error("Failed to fetch filters from PoE API: #{inspect(exception)}")
        {:error, "Network error: #{inspect(exception)}"}
    end
  end

  @doc """
  Fetches filter configuration, returning a fallback value on error.

  ## Examples

      iex> PoeProfit.PoeApi.Filters.fetch_or_default()
      %{"result" => [...]}
  """
  def fetch_or_default do
    case fetch() do
      {:ok, filters} -> filters
      {:error, _reason} -> default_filters()
    end
  end

  # Fallback filters when API is unavailable
  defp default_filters do
    %{
      "result" => [
        %{
          "id" => "status_filters",
          "filters" => [
            %{
              "id" => "status",
              "text" => "Status",
              "option" => %{
                "options" => [
                  %{"id" => "online", "text" => "Online"}
                ]
              }
            }
          ]
        }
      ]
    }
  end
end
