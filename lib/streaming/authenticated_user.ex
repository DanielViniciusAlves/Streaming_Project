defmodule Streaming.Authenticated.User do
  use GenServer, restart: :temporary
  require Logger

  alias Streaming.UserState
  alias Streaming.MessageHandler

  def start_link(opts, args) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init({name, uid, websocket_pid}) do
    Logger.info("Unauthenticated user started")

    state = %UserState{
      websocket_pid: websocket_pid,
      user_uid: uid,
      username: name,
      live_status: :offline,
      stream_uid: nil,
      stream_pid: nil,
      stream_key: request_database(uid, :stream_key)
    }

    {:ok, state}
  end

  # Genserver API

  def get_stream_key(pid) do
    GenServer.call(pid, :stream_key)
  end

  def register_stream(pid, stream_uid, stream_pid) do
    GenServer.cast(pid, {:update_stream, stream_uid, stream_pid})
  end

  def websocket_message(pid, message) do
    GenServer.cast(pid, {:websocket, message})
  end

  # Genserver callback funcionts

  def handle_call(:stream_key, _from, state) do
    {:reply, state.stream_key, state}
  end

  def handle_cast({:update_stream, stream_uid, stream_pid}, state) do
    {:noreply, %{state | stream_uid: stream_uid, stream_pid: stream_pid}}
  end

  def handle_cast(:end_of_stream, state) do
    {:noreply, %{state | stream_uid: nil, stream_pid: nil, live_status: :offline}}
  end

  def handle_cast(:disconnected, state) do
    Logger.error("Websocket connection closed on user #{state.username}")
    {:stop, :normal, state}
  end

  def handle_cast({:websocket, message}, state) do
    case treat_websocket_msg(message, state) do
      {:ok, state} ->
        {:noreply, state}

      {:error, reason} ->
        Logger.error("Error treating message: #{reason}")
        send(state.websocket_pid, :disconnect)
        {:stop, :normal, state}
    end
  end

  defp treat_websocket_msg(message, state) do
    case Jason.decode(message) do
      {:ok, decoded_msg} ->
        MessageHandler.message_handler(decoded_msg, state)

      {:error, reason} ->
        {:error, "Error decoding message #{reason.data}."}
    end
  end

  defp request_database(_user_uid, _field) do
    # Database request
    "teste123"
  end
end
