defmodule PoeProfit.Currencies.Currency do
  use Ash.Resource,
    otp_app: :poe_profit,
    domain: PoeProfit.Currencies,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "currencies"
    repo PoeProfit.Repo
  end

  actions do
    defaults [:read, update: :*]

    create :create do
      accept [:*]
      upsert? true
      upsert_identity :poe_id
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :poe_id, :string
    attribute :name, :string
    attribute :icon_url, :string
    attribute :league, :string
    attribute :price_in_exalted, :float
    attribute :last_price_update, :utc_datetime

    timestamps()
  end

  identities do
    identity :poe_id, [:poe_id, :league]
  end

  relationships do
    has_many :craft_currency_inputs, PoeProfit.Crafting.CraftCurrencyInput do
      public? true
    end
  end
end
