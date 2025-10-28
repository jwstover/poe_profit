defmodule PoeProfitWeb.FilterParamsHelper do
  @moduledoc """
  Helper functions for processing filter form parameters.
  """

  @doc """
  Recursively removes nil, empty strings, and empty maps from nested params.

  ## Examples

      iex> clean_params(%{filters: %{status_filters: %{filters: %{status: %{option: ""}}}}})
      %{}

      iex> clean_params(%{filters: %{status_filters: %{filters: %{status: %{option: "available"}}}}})
      %{filters: %{status_filters: %{filters: %{status: %{option: "available"}}}}}

      iex> clean_params(%{filters: %{fee: %{min: "10", max: ""}}})
      %{filters: %{fee: %{min: "10"}}}
  """
  def clean_params(params) when is_map(params) do
    params
    |> Enum.map(fn {k, v} -> {k, clean_value(v)} end)
    |> Enum.reject(fn {_k, v} -> is_empty?(v) end)
    |> Map.new()
    |> case do
      empty when empty == %{} -> nil
      cleaned -> cleaned
    end
  end

  def clean_params(value), do: value

  # Recursively clean nested maps
  defp clean_value(value) when is_map(value) do
    cleaned =
      value
      |> Enum.map(fn {k, v} -> {k, clean_value(v)} end)
      |> Enum.reject(fn {_k, v} -> is_empty?(v) end)
      |> Map.new()

    if map_size(cleaned) == 0, do: nil, else: cleaned
  end

  defp clean_value(value), do: value

  # Check if value should be considered empty
  defp is_empty?("Any"), do: true
  defp is_empty?("Any Time"), do: true
  defp is_empty?("Exalted Orb Equivalent"), do: true
  defp is_empty?("undefined"), do: true
  defp is_empty?(nil), do: true
  defp is_empty?(""), do: true
  defp is_empty?(map) when is_map(map), do: map_size(map) == 0
  defp is_empty?(_), do: false
end
