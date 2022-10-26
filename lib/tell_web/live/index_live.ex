defmodule TellWeb.IndexLive do
  use TellWeb, :live_view

  alias Conway.Cell
  alias Conway.World

  def mount(_params, _session, socket) do
    cells =
      for y <- 0..(World.height() - 1), x <- 0..(World.width() - 1) do
        %{
          alive?: Cell.alive?({x, y}),
          x: x,
          y: y,
          dot: Integer.mod(x + y, 6) + 1
        }
      end

    {:ok, assign(socket, cells: cells)}
  end
end
