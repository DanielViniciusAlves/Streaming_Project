defmodule Streaming.Router.WebsocketRouter do
  @behaviour :cowboy_websocket_handler

  alias Streaming.User.Supervisor, as: UserSupervisor
  require Logger

  def init(req, state) do
    Logger.info("Starting websocket user.")
    {:cowboy_websocket, req, state}
  end

  # Start websocket and create unathenticated user
  def websocket_init(state) do
    {:ok, user_pid} = UserSupervisor.start_unathenticated_user(Kernel.self())
    {:ok, Keyword.put_new(state, :user_pid, user_pid)}
  end

  # API for Websocket messages

  def websocket_handle({:ping, message}, state) do
    GenServer.cast(Keyword.get(state, :user_pid), {:websocket, message})
    {:ok, state}
  end

  def websocket_handle({:binary, message}, state) do
    GenServer.cast(Keyword.get(state, :user_pid), {:websocket, message})
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    GenServer.cast(Keyword.get(state, :user_pid), {:websocket, message})
    {:ok, state}
  end

  # API for Elixir messages

  def websocket_info({:send_message, :text, message}, state) do
    {[text: message], state}
  end

  def websocket_info({:send_message, :binary, message}, state) do
    {[binary: message], state}
  end

  def websocket_info({:send_message, :ping, message}, state) do
    {[ping: message], state}
  end

  def websocket_info({:update_user, user_pid}, state) do
    {:ok, Keyword.put(state, :user_pid, user_pid)}
  end

  def websocket_info(:disconnect, state) do
    {:stop, Keyword.put(state, :user_pid, nil)}
  end

  def websocket_info(message, state) do
    Logger.info("Message from Elixir proccess: #{message}")
    {:ok, state}
  end

  # Terminate callback for connection loss

  def terminate(reason, _req, state) do
    Logger.info("ws - disconnected, reason: #{inspect(reason)}, #{inspect(state)}")

    if Keyword.get(state, :user_pid) do
      GenServer.cast(Keyword.get(state, :user_pid), :disconnected)
    end

    :ok
  end
end
