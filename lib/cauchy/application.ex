defmodule Cauchy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CauchyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Cauchy.PubSub},
      # Start Finch
      {Finch, name: Cauchy.Finch},
      # Start the Endpoint (http/https)
      CauchyWeb.Endpoint
      # Start a worker by calling: Cauchy.Worker.start_link(arg)
      # {Cauchy.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cauchy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CauchyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
