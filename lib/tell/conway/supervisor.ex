defmodule Conway.Supervisor do
  use Supervisor

  # Start

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # OTP

  @impl true
  def init(_) do
    children = [
      Conway.Game,
      {Registry, keys: :unique, name: Conway.Cell.Registry},
      {DynamicSupervisor, name: Conway.Cell.DynamicSupervisor},
      Conway.Ticker
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
