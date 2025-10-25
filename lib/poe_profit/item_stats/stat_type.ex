defmodule PoeProfit.ItemStats.StatType do
  use Ash.Resource,
    otp_app: :poe_profit,
    domain: PoeProfit.ItemStats,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "stat_types"
    repo PoeProfit.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:*]
      upsert? true
      upsert_identity :name
      upsert_fields [:name]
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :name, [:name]
  end
end
