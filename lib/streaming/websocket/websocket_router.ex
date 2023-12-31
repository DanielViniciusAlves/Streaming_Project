defmodule Streaming.Router.WebsocketRouter do
  @behaviour :cowboy_websocket_handler

  alias Streaming.Authenticated.User, as: AuthenticatedUser
  alias Streaming.User.Supervisor, as: UserSupervisor
  require Logger

  def init(req, state) do
    Logger.info("Starting websocket user.")

    case validate_header(req.headers["user_info"]) do
      :ok ->
        {:cowboy_websocket, req, state, %{idle_timeout: 10000}}

      {:error, reason} ->
        Logger.error(reason)
        {:stop, :normal, state}
    end
  end

  # Start websocket and create unathenticated user
  def websocket_init(state) do
    {:ok, user_pid} = UserSupervisor.start_unathenticated_user(Kernel.self())
    {:ok, Keyword.put_new(state, :user_pid, user_pid)}
  end

  # API for Websocket messages

  def websocket_handle({:ping, message}, state) do
    AuthenticatedUser.websocket_message(Keyword.get(state, :user_pid), message)
    {:ok, state}
  end

  def websocket_handle({:binary, message}, state) do
    AuthenticatedUser.websocket_message(Keyword.get(state, :user_pid), message)
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    AuthenticatedUser.websocket_message(Keyword.get(state, :user_pid), message)
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
    Logger.error("Websocket disconnected: #{inspect(reason)}, #{inspect(state)}")

    if Keyword.get(state, :user_pid) do
      GenServer.cast(Keyword.get(state, :user_pid), :disconnected)
    end

    :ok
  end

  def validate_header(info) do
    IO.inspect(info)
    # Verify if the database has this info
    :ok
  end
end
