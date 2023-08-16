defmodule Streaming.Router.WebsocketRouter do
  @behaviour :cowboy_websocket_handler

  require Logger

  def init(req, state) do
    Logger.info("ws - got connection...")
    {:cowboy_websocket, req, state}
  end

  def websocket_init([handler | assigns]) do
    Swarm.register_name("websocket", Kernel.self)
    {:ok, assigns} = handler.init(assigns)
    {:ok, [handler | assigns]}
  end

  def websocket_handle({msg_type, message}, state) do
    IO.inspect message
    {[binary: message], state}
  end

  def websocket_info(_info, state) do
    Logger.warn("ws - websocket_info")
    {:ok, state}
  end

  def terminate(reason, _req, state) do
    Logger.info("ws - disconnected, reason: #{inspect(reason)}, #{inspect(state)}")
    :ok
  end
end
