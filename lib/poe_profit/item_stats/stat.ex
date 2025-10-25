defmodule PoeProfit.ItemStats.Stat do
  use Ash.Resource,
    otp_app: :poe_profit,
    domain: PoeProfit.ItemStats,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "stats"
    repo PoeProfit.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:*]
      upsert? true
      upsert_identity :poe_id
      upsert_fields []
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :poe_id, :string do
      public? true
      allow_nil? false
    end

    attribute :text, :string do
      public? true
      allow_nil? false
    end
  end

  relationships do
    belongs_to :type, PoeProfit.ItemStats.StatType, public?: true, allow_nil?: false
  end

  identities do
    identity :poe_id, [:poe_id, :text]
  end
end
