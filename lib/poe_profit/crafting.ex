defmodule PoeProfit.Crafting do
  use Ash.Domain,
    otp_app: :poe_profit

  resources do
    resource PoeProfit.Crafting.Craft do
      define :list_crafts, action: :read
      define :get_craft, action: :read, get?: true
      define :create_craft, action: :create
      define :update_craft, action: :update
      define :delete_craft, action: :destroy
    end

    resource PoeProfit.Crafting.CraftCurrencyInput
    resource PoeProfit.Crafting.CraftItemInput
    resource PoeProfit.Crafting.CraftOutcome
    resource PoeProfit.Crafting.CraftPriceSnapshot
  end
end
