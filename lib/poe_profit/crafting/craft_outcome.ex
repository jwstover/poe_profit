defmodule PoeProfit.Crafting.CraftOutcome do
  use Ash.Resource,
    otp_app: :poe_profit,
    domain: PoeProfit.Crafting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "craft_outcomes"
    repo PoeProfit.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:probability, :outcome_item_query, :description, :craft_id]
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :probability, :float do
      public? true
      allow_nil? false
    end

    attribute :outcome_item_query, :map do
      public? true
    end

    attribute :description, :string do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :craft, PoeProfit.Crafting.Craft do
      public? true
      allow_nil? false
    end
  end
end
