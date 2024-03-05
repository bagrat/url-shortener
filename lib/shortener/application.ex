defmodule Shortener.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShortenerWeb.Telemetry,
      Shortener.Repo,
      {DNSCluster, query: Application.get_env(:shortener, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Shortener.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Shortener.Finch},
      # Start a worker by calling: Shortener.Worker.start_link(arg)
      # {Shortener.Worker, arg},
      # Start to serve requests, typically the last entry
      ShortenerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shortener.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShortenerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
