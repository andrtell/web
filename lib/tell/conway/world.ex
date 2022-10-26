defmodule Conway.World do
  @world_boundries %{w: 24, h: 48}

  def normalize_position({x, y}) do
    {Integer.mod(x, @world_boundries.w), Integer.mod(y, @world_boundries.h)}
  end

  def width, do: @world_boundries.w
  def height, do: @world_boundries.h
end
