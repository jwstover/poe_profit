defmodule PoeProfit.Currencies do
  use Ash.Domain,
    otp_app: :poe_profit

  resources do
    resource PoeProfit.Currencies.Currency
  end
end
