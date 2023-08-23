defmodule Streaming.RTMP.Validator do
  defstruct [
    :user_pid,
    :stream_uid
  ]
end

defimpl Membrane.RTMP.MessageValidator, for: Streaming.RTMP.Validator do
  require Logger
  alias Streaming.Authenticated.User, as: AuthenticatedUser

  @impl Membrane.RTMP.MessageValidator
  def validate_set_data_frame(_info, _message) do
    {:ok, "Validate data frame successfull"}
  end

  @impl Membrane.RTMP.MessageValidator
  def validate_publish(info, message) do
    case validate_rtmp(message.stream_key, info) do
      {:ok, state} ->
        {:ok, "Validate publish message successfull", state}

      _ ->
        {:ok, {:error, "Error in the release validation"}}
    end
  end

  @impl Membrane.RTMP.MessageValidator
  def validate_release_stream(info, message) do
    case validate_rtmp(message.stream_key, info) do
      {:ok, state} ->
        {:ok, "Validate release message successfull", state}

      _ ->
        {:ok, {:error, "Error in the release validation"}}
    end
  end

  defp validate_rtmp(rtmp_key, info) do
    [user_uid | stream_key] = String.split(rtmp_key, "_")

    case stream_validation(user_uid, stream_key, info) do
      :error ->
        Logger.error("Stream validation Failed")

        :error

      {:ok, info} ->
        {:ok, info}
    end
  end

  defp stream_validation(user_uid, stream_key, info) do
    case Swarm.whereis_name(user_uid) do
      :undefined ->
        Logger.error("User UID #{user_uid} not found!")
        :error

      pid ->
        user_stream_key = AuthenticatedUser.get_stream_key(pid)

        cond do
          user_stream_key == stream_key ->
            AuthenticatedUser.register_stream(pid, info.stream_uid, Kernel.self())
            {:ok, %{info | user_pid: pid}}

          true ->
            Logger.error("Stream Key not valid!")
            :error
        end
    end
  end
end
