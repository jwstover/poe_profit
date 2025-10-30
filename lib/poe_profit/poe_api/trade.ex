defmodule PoeProfit.PoeApi.Trade do
  @moduledoc """
  Client for fetching trade data from the Path of Exile Trade API.
  """

  require Logger

  @base_url "https://www.pathofexile.com/api/trade2"

  def search(params) do
    url = Path.join(@base_url, "/search/poe2/Rise%20of%20the%20Abyssal")
    body = %{query: params, sort: %{price: "asc"}} |> Jason.encode!()
    headers = [{"content-type", "application/json"}]

    Req.post(url, headers: headers, body: body)
    |> case do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {_, %{status: status} = err} ->
        Logger.error("PoE API returned status #{status}")
        {:error, err}
    end
  end

  def get_items([], _, _), do: {:ok, []}

  def get_items(item_ids, query_id, realm \\ "poe2") do
    query = %{query: query_id, realm: realm}

    url =
      Path.join(@base_url, "/fetch/#{Enum.join(item_ids, ",")}?#{URI.encode_query(query)}")

    Req.get(url)
    |> case do
      {:ok, %{status: 200, body: %{"result" => result}}} ->
        {:ok, result}

      {_, %{status: status} = err} ->
        Logger.error("PoE API returned status #{status}")
        {:error, err}
    end
  end
end
