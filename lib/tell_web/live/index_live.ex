defmodule TellWeb.IndexLive do
  use TellWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
