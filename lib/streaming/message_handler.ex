defmodule Streaming.MessageHandler do
  alias Phoenix.PubSub
  alias Streaming.LivestreamChat.PubSub, as: LivestreamChat
  require Logger

  def message_handler(message, state) do
    Map.get(message, "message_type") |> String.to_atom() |> on_message(message, state)
  end

  def on_message(:private_message, decoded_message, state) do
    destination_uid = Map.get(decoded_message, "destination_uid")
    # register_message_database(decoded_message)
    case Swarm.whereis_name(destination_uid) do
      :undefined ->
        Logger.info("Destinatio User offline.")

      destination_pid ->
        GenServer.cast(destination_pid, {:private_message, Map.get(decoded_message, "message")})
    end

    {:ok, state}
  end

  def on_message(:group_message, decoded_message, state) do
    participants_uid = Map.get(decoded_message, "participants_uid")
    # register_message_database(decoded_message)
    Enum.each(participants_uid, fn destination_uid -> 
      case Swarm.whereis_name(destination_uid) do
        :undefined ->
          Logger.info("Destinatio User offline.")

        destination_pid ->
          GenServer.cast(destination_pid, {:private_message, Map.get(decoded_message, "message")})
      end
    end)
    {:ok, state}
  end

  def on_message(:live_message, decoded_message, state) do
    livestream_uid = Map.get(decoded_message, "livestream_uid")
    PubSub.broadcast(LivestreamChat, livestream_uid, Map.get(decoded_message, "message"))
    {:ok, state}
  end

  def on_message(:enter_live_chat, decoded_message, state) do
    livestream_uid = Map.get(decoded_message, "livestream_uid")
    PubSub.subscribe(LivestreamChat, livestream_uid)
    {:ok, state}
  end

  def on_message(:leave_live_chat, decoded_message, state) do
    livestream_uid = Map.get(decoded_message, "livestream_uid")
    PubSub.unsubscribe(LivestreamChat, livestream_uid)
    {:ok, state}
  end
end
