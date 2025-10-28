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
      |> assign(:loading, false)
      |> assign(:query_id, nil)
      |> stream_configure(:items, dom_id: & &1["id"])
      |> stream(:items, [])

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    # Extract and clean filter params from URL
    filter_params = FilterParamsHelper.clean_params(params) || %{}

    socket =
      socket
      |> assign(:filter_params, filter_params)
      |> assign(:form, to_form(filter_params, as: "filters"))

    {:noreply, socket}
  end

  def handle_event("filter_change", params, socket) do
    # Extract just the filter data, excluding Phoenix form tracking fields like _target
    filter_data = Map.get(params, "filters", %{})
    cleaned_params = FilterParamsHelper.clean_params(%{"filters" => filter_data}) || %{}

    {:noreply, push_patch(socket, to: ~p"/items?#{cleaned_params}")}
  end

  def handle_event("search", params, socket) do
    cleaned_params =
      (FilterParamsHelper.clean_params(params) || %{})
      |> Map.put_new("status", %{"option" => "securable"})

    with {:ok, %{"id" => query_id, "result" => item_ids}} <- Trade.search(cleaned_params),
         item_ids <- Enum.take(item_ids, 10),
         {:ok, items} <- Trade.get_items(item_ids, query_id) do
      {:noreply, socket |> assign(:query_id, query_id) |> stream(:items, items, reset: true)}
    end
  end

  defp format_mod(mod_string) do
    # Replace [InternalName|Display Text] with Display Text, or [Value] with Value
    Regex.replace(~r/\[([^|\]]+)(?:\|([^\]]+))?\]/, mod_string, fn
      _, first, "" -> first
      _, _internal, display -> display
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">Item Search</h1>

      <.form for={@form} phx-change="filter_change" phx-submit="search">
        <FiltersComponent.filters filters_data={@filters_config} form={@form} />

        <.button type="submit">Search Items</.button>
      </.form>

      <div :if={@query_id}>
        <a
          href={"https://pathofexile.com/trade2/search/poe2/Rise%20of%20the%20Abyssal/#{@query_id}"}
          target="_blank"
        >
          <.button variant="primary">View on Trade Site</.button>
        </a>
      </div>

      <div>
        <div
          :for={{dom_id, item} <- @streams.items}
          id={dom_id}
          class="grid grid-cols-[100px_1fr_100px]"
        >
          <div><img src={item["item"]["icon"]} /></div>
          <div>
            <h3>{item["item"]["name"]} {item["item"]["typeLine"]}</h3>
            <ul>
              <li :for={mod <- item["item"]["explicitMods"] || []}>{format_mod(mod)}</li>
            </ul>
          </div>
          <div></div>
        </div>
      </div>
    </div>
    """
  end
end
