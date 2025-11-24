defmodule PoeProfit.Crafting.CraftItemInput do
  use Ash.Resource,
    otp_app: :poe_profit,
    domain: PoeProfit.Crafting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "craft_item_inputs"
    repo PoeProfit.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:item_query, :quantity, :description, :craft_id]
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :item_query, :map do
      public? true
    end

    attribute :quantity, :integer do
      public? true
      allow_nil? false
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
