defmodule PoeProfit.Repo do
  use Ecto.Repo,
    otp_app: :poe_profit,
    adapter: Ecto.Adapters.Postgres
end
