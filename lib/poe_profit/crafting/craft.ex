defmodule PoeProfit.Crafting.Craft do
  use Ash.Resource,
    otp_app: :poe_profit,
    domain: PoeProfit.Crafting,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "crafts"
    repo PoeProfit.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:name, :description, :league, :is_public, :base_item_query, :user_id]
    end
  end

  policies do
    # Users can read their own crafts or public crafts
    policy action_type(:read) do
      authorize_if expr(user_id == ^actor(:id))
      authorize_if expr(is_public == true)
    end

    # Only owner can modify
    policy action_type([:create, :update, :destroy]) do
      authorize_if expr(user_id == ^actor(:id))
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      public? true
      allow_nil? false
    end

    attribute :description, :string do
      public? true
    end

    attribute :league, :string do
      public? true
      allow_nil? false
    end

    attribute :is_public, :boolean do
      public? true
      default false
    end

    attribute :base_item_query, :map do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, PoeProfit.Accounts.User do
      public? true
      allow_nil? true
    end

    has_many :craft_currency_inputs, PoeProfit.Crafting.CraftCurrencyInput do
      public? true
    end

    has_many :craft_item_inputs, PoeProfit.Crafting.CraftItemInput do
      public? true
    end

    has_many :craft_outcomes, PoeProfit.Crafting.CraftOutcome do
      public? true
    end

    has_many :price_snapshots, PoeProfit.Crafting.CraftPriceSnapshot do
      public? true
    end
  end
end
