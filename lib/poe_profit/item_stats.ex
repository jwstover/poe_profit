defmodule PoeProfit.ItemStats do
  use Ash.Domain,
    otp_app: :poe_profit

  alias PoeProfit.ItemStats.Stat
  alias PoeProfit.ItemStats.StatType

  @api_url "https://www.pathofexile.com/api/trade2/data/stats"

  resources do
    resource PoeProfit.ItemStats.StatType do
      define :create_stat_type, action: :create
      define :list_stat_types, action: :read
    end

    resource PoeProfit.ItemStats.Stat do
      define :list_stats, action: :read
    end
  end

  @doc """
  Load item stats and stat_types from POE API
  """
  def load do
    with {:ok, stat_groups} <- fetch_stats() do
      Enum.reduce_while(stat_groups, :ok, fn stat_group, :ok ->
        load_stat_group(stat_group)
        |> case do
          :ok -> {:cont, :ok}
          err -> {:halt, err}
        end
      end)
    end
  end

  defp load_stat_group(%{"label" => label, "entries" => entries})
       when is_binary(label) and is_list(entries) do
    with {:ok, %StatType{id: type_id}} <- create_stat_type(%{name: label}) do
      entries
      |> Enum.map(fn %{"id" => poe_id, "text" => text} ->
        %{
          poe_id: poe_id,
          text: text,
          type_id: type_id
        }
      end)
      |> Ash.bulk_create(Stat, :create)
      |> case do
        %{status: :success} -> :ok
        err -> {:error, err}
      end
    end
  end

  defp fetch_stats do
    Req.get(@api_url)
    |> case do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body["result"]}

      {_, err} ->
        {:error, err}
    end
  end
end
