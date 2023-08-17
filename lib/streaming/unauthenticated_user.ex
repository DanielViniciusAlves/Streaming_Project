defmodule Streaming.Unauthenticated.User do
  alias Streaming.Unauthenticated
  use GenServer, restart: :temporary
  require Logger

  def start_link(opts, args) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init({websocket_pid}) do
    Logger.info "Unauthenticated user started"

    {:ok, %{websocket_pid: websocket_pid}}
  end

  def handle_cast({:websocket, message}, state) do
    # case treat_websocket_msg(message) do
    #   {:ok, state} ->
    #     {:ok, state}
    #   {:error, reason} ->
    #     Logger.error "Error treating message: #{reason}"
    #     {:ok, state}
    # end
    send(state.websocket_pid, :disconnect)
    {:noreply, state}
  end

  def handle_cast(:disconnect, state) do
    {:stop, :normal, state}
  end

  def treat_websocket_msg(message) do
    
  end
end
