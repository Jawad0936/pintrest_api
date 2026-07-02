defmodule PinterestApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PinterestApiWeb.Telemetry,
      PinterestApi.Repo,
      {DNSCluster, query: Application.get_env(:pinterest_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PinterestApi.PubSub},
      # Start a worker by calling: PinterestApi.Worker.start_link(arg)
      # {PinterestApi.Worker, arg},
      # Start to serve requests, typically the last entry
      PinterestApiWeb.Endpoint,
      {Absinthe.Subscription, PinterestApiWeb.Endpoint}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PinterestApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PinterestApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
