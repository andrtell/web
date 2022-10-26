defmodule Conway.Cell do
  use GenServer, restart: :transient

  alias Conway.World

  @offsets [
    {-1, -1},
    {0, -1},
    {1, -1},
    {-1, 0},
    {1, 0},
    {-1, 1},
    {0, 1},
    {1, 1}
  ]

  # Start

  def start_link(position) do
    world_position = World.normalize_position(position)

    GenServer.start_link(
      __MODULE__,
      world_position,
      name: {
        :via,
        Registry,
        {Conway.Cell.Registry, world_position}
      }
    )
  end

  @impl true
  def init({_x, _y} = position), do: {:ok, position}

  # API

  def alive?(position), do: lookup(position) != nil

  def dead?(position), do: !alive?(position)

  def position(pid), do: GenServer.call(pid, :position)

  def tick(pid), do: GenServer.call(pid, :tick)

  def sow(position) do
    DynamicSupervisor.start_child(Conway.Cell.DynamicSupervisor, {__MODULE__, position})
  end

  def reap(pid) do
    DynamicSupervisor.terminate_child(Conway.Cell.DynamicSupervisor, pid)
  end

  def lookup(position) do
    Registry.lookup(Conway.Cell.Registry, position)
    |> Enum.map(fn
      {pid, _} -> pid
      nil -> nil
    end)
    |> Enum.filter(&Process.alive?/1)
    |> List.first()
  end

  def all() do
    Conway.Cell.DynamicSupervisor
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  # OTP

  @impl true
  def handle_call(:position, _from, position), do: {:reply, position, position}

  @impl true
  def handle_call(:tick, _from, position) do
    to_reap =
      position
      |> count_neighbours
      |> case do
        2 -> []
        3 -> []
        _ -> [self()]
      end

    to_sow =
      position
      |> neighbours
      |> keep_dead
      |> keep_to_birth

    {:reply, {to_reap, to_sow}, position}
  end

  # Private

  defp count_neighbours(position) do
    position
    |> neighbours
    |> keep_live
    |> length
  end

  defp neighbours({x, y}) do
    @offsets
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.map(&World.normalize_position/1)
  end

  defp keep_live(positions) do
    Enum.filter(positions, &alive?/1)
  end

  defp keep_dead(positions) do
    Enum.filter(positions, &dead?/1)
  end

  defp keep_to_birth(positions) do
    positions
    |> Enum.filter(&(count_neighbours(&1) == 3))
  end
end
