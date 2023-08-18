defmodule Streaming.Unauthenticated.User do
  alias Streaming.User.Supervisor, as: UserSupervisor
  use GenServer, restart: :temporary
  require Logger

  def start_link(opts, args) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init({websocket_pid}) do
    Logger.info("Unauthenticated user started")

    {:ok, %{websocket_pid: websocket_pid}}
  end

  def handle_cast({:websocket, message}, state) do
    case treat_websocket_msg(message, state) do
      :ok ->
        {:stop, :normal, state}

      {:error, reason} ->
        Logger.error("Error treating message: #{reason}")
        send(state.websocket_pid, :disconnect)
        {:stop, :normal, state}
    end
  end

  def handle_cast(:disconnected, state) do
    Logger.error("Websocket connection closed.")
    {:stop, :normal, state}
  end

  defp treat_websocket_msg(message, state) do
    case Jason.decode(message) do
      {:ok, decoded_msg} ->
        with uid when is_integer(uid) <- Map.get(decoded_msg, "uid"),
             name when is_binary(name) <- Map.get(decoded_msg, "name") do
          case check_database(name, uid) do
            :ok ->
              pid = UserSupervisor.start_user(name, uid, state.websocket_pid)
              send(state.websocket_pid, {:update_user, pid})
              :ok

            {:error, reason} ->
              {:error, reason}
          end
        else
          _ ->
            {:error, "Invalid UID or Name format in message."}
        end

      {:error, reason} ->
        {:error, "Error decoding message #{reason.data}."}
    end
  end

  defp check_database(name, pid) do
    # Verify data in database
    :ok
  end
end
