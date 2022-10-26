defmodule Tell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TellWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Tell.PubSub},
      # Start the Endpoint (http/https)
      TellWeb.Endpoint,
      # Start a worker by calling: Tell.Worker.start_link(arg)
      # {Tell.Worker, arg}
      Conway.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tell.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TellWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
