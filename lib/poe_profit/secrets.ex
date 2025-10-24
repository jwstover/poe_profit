defmodule PoeProfit.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        PoeProfit.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:poe_profit, :token_signing_secret)
  end
end
