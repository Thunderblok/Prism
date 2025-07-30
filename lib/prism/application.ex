defmodule Prism.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PrismWeb.Telemetry,
      Prism.Repo,
      {DNSCluster, query: Application.get_env(:prism, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Prism.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Prism.Finch},
      # Start a worker by calling: Prism.Worker.start_link(arg)
      # {Prism.Worker, arg},
      # Start to serve requests, typically the last entry
      PrismWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Prism.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PrismWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
