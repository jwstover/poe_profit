defmodule PoeProfit.Accounts do
  use Ash.Domain, otp_app: :poe_profit, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource PoeProfit.Accounts.Token
    resource PoeProfit.Accounts.User
  end
end
