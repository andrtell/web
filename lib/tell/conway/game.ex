defmodule Conway.Game do
  use GenServer

  alias Conway.Cell

  # Start

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, []}
  end

  # API

  def tick(), do: GenServer.call(__MODULE__, :tick)

  def positions(), do: GenServer.call(__MODULE__, :positions)

  def seed(to_sow), do: GenServer.call(__MODULE__, {:seed, to_sow})

  # OTP

  def handle_call(:tick, _from, []) do
    Cell.all()
    |> each_tick
    |> each_await
    |> reduce_ticks
    |> reap_and_sow

    {:reply, :ok, []}
  end

  def handle_call(:positions, _from, []) do
    positions =
      Cell.all()
      |> each_position
      |> each_await
      |> Enum.map(fn {x, y} -> %{x: x, y: y} end)

    {:reply, positions, []}
  end

  def handle_call({:seed, to_sow}, _from, []) do
    Enum.map(to_sow, &Cell.sow/1)
    {:reply, :ok, []}
  end

  # Private

  defp each_tick(pids) do
    pids
    |> Enum.map(&Task.async(fn -> Cell.tick(&1) end))
  end

  defp each_position(pids) do
    pids
    |> Enum.map(&Task.async(fn -> Cell.position(&1) end))
  end

  defp each_await(tasks) do
    tasks
    |> Enum.map(&Task.await/1)
  end

  defp reduce_ticks(ticks) do
    Enum.reduce(ticks, {[], []}, &accumulate_ticks/2)
  end

  defp accumulate_ticks({reap, sow}, {acc_reap, acc_sow}) do
    {acc_reap ++ reap, acc_sow ++ sow}
  end

  defp reap_and_sow({to_reap, to_sow}) do
    Enum.map(to_reap, &Cell.reap/1)
    # with map we will discard errors on duplicate positions to sow
    Enum.map(to_sow, &Cell.sow/1)
  end
end
