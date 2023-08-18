defmodule Streaming.Authenticated.User do
  use GenServer, restart: :temporary
  require Logger

  def start_link(opts, args) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init({name, uid, websocket_pid}) do
    Logger.info("Unauthenticated user started")

    {:ok, %{websocket_pid: websocket_pid}}
  end
end
