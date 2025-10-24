defmodule PoeProfit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PoeProfitWeb.Telemetry,
      PoeProfit.Repo,
      {DNSCluster, query: Application.get_env(:poe_profit, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PoeProfit.PubSub},
      # Start a worker by calling: PoeProfit.Worker.start_link(arg)
      # {PoeProfit.Worker, arg},
      # Start to serve requests, typically the last entry
      PoeProfitWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PoeProfit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PoeProfitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
