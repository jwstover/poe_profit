defmodule PoeProfit.Crafting.CraftPriceSnapshot do
  use Ash.Resource,
    otp_app: :poe_profit,
    domain: PoeProfit.Crafting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "craft_price_snapshots"
    repo PoeProfit.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [
        :snapshot_at,
        :total_input_cost_exalted,
        :expected_output_value_exalted,
        :expected_profit_exalted,
        :price_breakdown,
        :craft_id
      ]
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :snapshot_at, :utc_datetime do
      public? true
      allow_nil? false
    end

    attribute :total_input_cost_exalted, :float do
      public? true
      allow_nil? false
    end

    attribute :expected_output_value_exalted, :float do
      public? true
      allow_nil? false
    end

    attribute :expected_profit_exalted, :float do
      public? true
      allow_nil? false
    end

    attribute :price_breakdown, :map do
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
