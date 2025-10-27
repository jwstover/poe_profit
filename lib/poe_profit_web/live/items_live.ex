defmodule PoeProfitWeb.ItemsLive do
  @moduledoc false

  use PoeProfitWeb, :live_view

  alias PoeProfitWeb.{FiltersComponent, FilterParamsHelper}
  alias PoeProfit.PoeApi.Filters
  alias PoeProfit.PoeApi.Trade

  def mount(_params, _session, socket) do
    # Fetch filters from PoE API
    filters_config = Filters.fetch_or_default()

    socket =
      socket
      |> assign(:filters_config, filters_config)
      |> assign(:filter_params, %{})
      |> assign(:form, to_form(%{}, as: "filters"))
      |> assign(:loading, false)
      |> assign(:query_id, nil)

    {:ok, socket}
  end

  def handle_event("filter_change", params, socket) do
    cleaned_params = FilterParamsHelper.clean_params(params) || %{}

    {:noreply, assign(socket, :filter_params, cleaned_params)}
  end

  def handle_event("search", params, socket) do
    cleaned_params =
      (FilterParamsHelper.clean_params(params) || %{})
      |> Map.put_new("status", %{"option" => "securable"})

    with {:ok, %{"id" => query_id, "result" => item_ids}} <- Trade.search(cleaned_params),
         item_ids <- Enum.take(item_ids, 10),
         {:ok, items} <- Trade.get_items(item_ids, query_id) do
      {:noreply, socket |> assign(:query_id, query_id)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">Item Search</h1>

      <.form for={@form} phx-change="filter_change" phx-submit="search">
        <FiltersComponent.filters filters_data={@filters_config} />

        <.button type="submit">Search Items</.button>
      </.form>

      <div :if={@query_id}>
        <a href={"https://pathofexile.com/trade2/search/poe2/Rise%20of%20the%20Abyssal/#{@query_id}"} target="_blank">
          <.button variant="primary">View on Trade Site</.button>
        </a>
      </div>
    </div>
    """
  end
end
