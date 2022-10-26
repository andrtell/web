defmodule Conway.Ticker do
  use GenServer

  alias Conway.Game
  alias Conway.Patterns

  # Start

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  # OTP

  @impl true
  def init(_) do
    :timer.send_interval(:timer.minutes(10), :tick)
    seed_game()
    {:ok, 1}
  end

  @impl true
  def handle_info(:tick, state) do
    if Integer.mod(state, 300) == 0, do: seed_game()
    Game.tick()
    {:noreply, state + 1}
  end

  defp seed_game() do
    Game.seed(Patterns.tumbler(r(), r()))
    Game.seed(Patterns.tumbler(r(), r()))
    Game.seed(Patterns.tumbler(r(), r()))
    Game.seed(Patterns.glider(r(), r()))
    Game.seed(Patterns.glider(r(), r()))
  end

  def r(), do: Enum.random(0..100)
end
