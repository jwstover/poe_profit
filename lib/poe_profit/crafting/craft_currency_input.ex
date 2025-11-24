defmodule PoeProfit.Crafting.CraftCurrencyInput do
  use Ash.Resource,
    otp_app: :poe_profit,
    domain: PoeProfit.Crafting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "craft_currency_inputs"
    repo PoeProfit.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:quantity, :craft_id, :currency_id]
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :quantity, :integer do
      public? true
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :craft, PoeProfit.Crafting.Craft do
      public? true
      allow_nil? false
    end

    belongs_to :currency, PoeProfit.Currencies.Currency do
      public? true
      allow_nil? false
    end
  end
end
