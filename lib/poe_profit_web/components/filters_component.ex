defmodule PoeProfitWeb.FiltersComponent do
  use Phoenix.Component
  import PoeProfitWeb.CoreComponents, only: [input: 1]

  @doc """
  Renders a dynamic filter form based on API response structure.

  Generates nested input names that match the API structure:
  filters[group_id][filters][filter_id][option]

  ## Examples

      <.filters filters_data={@filters_config} />
  """
  attr :filters_data, :map, required: true

  def filters(assigns) do
    ~H"""
    <div class="filters-container w-full flex flex-col gap-2">
      <%= for group <- Map.get(@filters_data, "result", []) do %>
        <.filter_group group={group} />
      <% end %>
    </div>
    """
  end

  defp filter_group(%{group: %{"id" => "status_filters"}} = assigns), do: ~H""

  defp filter_group(assigns) do
    ~H"""
    <div class="card w-full bg-base-200">
      <div class="card-body p-0">
        <div class={"collapse collapse-arrow bg-base-200 #{if !@group["hidden"], do: "collapse-open"}"}>
          <input type="checkbox" checked={!@group["hidden"]} />
          <div class="collapse-title text-lg font-semibold">
            {@group["title"] || humanize(@group["id"])}
          </div>
          <div class="collapse-content">
            <fieldset class="filter-group w-full" id={@group["id"]}>
              <div class="grid grid-cols-2 gap-x-2 pt-2">
                <%= for filter <- Map.get(@group, "filters", []) do %>
                  <.filter_input filter={filter} group_id={@group["id"]} />
                <% end %>
              </div>
            </fieldset>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Pattern match: combined minMax with option dropdown (e.g., price with currency selection)
  defp filter_input(assigns)
       when is_map_key(assigns.filter, "minMax") and is_map_key(assigns.filter, "option") do
    raw_options = get_in(assigns.filter, ["option", "options"]) || []
    # Convert API options to {label, value} tuples, filtering out disabled string headers
    options = transform_options(raw_options)
    assigns = assign(assigns, :options, options)

    ~H"""
    <div class={filter_class(@filter)}>
      <div class="grid grid-cols-[1fr_75px_75px] gap-2 items-end">
        <.input
          type="type_ahead_select"
          id={build_input_id(@group_id, @filter["id"])}
          name={build_input_name(@group_id, @filter["id"], "option")}
          label={@filter["text"] || humanize(@filter["id"])}
          options={@options}
          prompt="Select..."
        />
        <input
          type="number"
          name={build_input_name(@group_id, @filter["id"], "min")}
          placeholder="Min"
          class="py-1 px-2 bg-base-300"
        />
        <input
          type="number"
          name={build_input_name(@group_id, @filter["id"], "max")}
          placeholder="Max"
          class="py-1 px-2 bg-base-300"
        />
      </div>
    </div>
    """
  end

  # Pattern match: minMax range inputs only
  defp filter_input(assigns) when is_map_key(assigns.filter, "minMax") do
    ~H"""
    <div class={filter_class(@filter)}>
      <div class="grid grid-cols-[auto_75px_75px] w-full items-end p-1 gap-2">
        <label class="block flex-1 font-medium mb-1">
          {@filter["text"] || humanize(@filter["id"])}
        </label>
        <input
          type="number"
          name={build_input_name(@group_id, @filter["id"], "min")}
          placeholder="Min"
          class="py-1 px-2 bg-base-300"
        />
        <input
          type="number"
          name={build_input_name(@group_id, @filter["id"], "max")}
          placeholder="Max"
          class="py-1 px-2 bg-base-300"
        />
      </div>
    </div>
    """
  end

  # Pattern match: select dropdown with options only
  defp filter_input(assigns) when is_map_key(assigns.filter, "option") do
    raw_options = get_in(assigns.filter, ["option", "options"]) || []
    # Convert API options to {label, value} tuples, filtering out disabled string headers
    options = transform_options(raw_options)
    assigns = assign(assigns, :options, options)

    ~H"""
    <div class={filter_class(@filter)}>
      <.input
        type="type_ahead_select"
        id={build_input_id(@group_id, @filter["id"])}
        name={build_input_name(@group_id, @filter["id"], "option")}
        label={@filter["text"] || humanize(@filter["id"])}
        options={@options}
        prompt="Select..."
      />
    </div>
    """
  end

  # Pattern match: text input (fallback)
  defp filter_input(assigns) do
    ~H"""
    <div class={filter_class(@filter)}>
      <label class="block text-sm font-medium mb-1">
        {@filter["text"] || humanize(@filter["id"])}
      </label>
      <input
        type="text"
        name={build_input_name(@group_id, @filter["id"], "value")}
        class="w-full py-1 px-2 bg-base-300"
      />
    </div>
    """
  end

  # Builds nested input name: filters[group_id][filters][filter_id][key]
  defp build_input_name(group_id, filter_id, key) do
    "filters[#{group_id}][filters][#{filter_id}][#{key}]"
  end

  # Builds unique input ID for filter
  defp build_input_id(group_id, filter_id) do
    "filter-#{group_id}-#{filter_id}"
  end

  # Transforms API options format to {label, value} tuples for type_ahead_select
  # Filters out disabled string options (category headers)
  defp transform_options(options) do
    options
    |> Enum.reject(&is_binary/1)
    |> Enum.map(fn opt -> {opt["text"], opt["id"]} end)
  end

  # Determines CSS class based on fullSpan property
  defp filter_class(filter) do
    base = "filter-input mb-4"
    if filter["fullSpan"], do: base <> " col-span-2", else: base
  end

  # Humanizes filter ID for display
  defp humanize(id) when is_binary(id) do
    id
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp humanize(_), do: ""
end
