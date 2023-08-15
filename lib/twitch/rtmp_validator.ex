defmodule Twitch.RTMP.Validator do

  defstruct [
    :validator_pid,
  ]
end

defimpl Membrane.RTMP.MessageValidator, for: Twitch.RTMP.Validator do
  alias Twitch.User.Validator, as: UserValidator

  @impl Membrane.RTMP.MessageValidator
  def validate_set_data_frame(_info, _message) do
    {:ok, "Validate data frame successfull"}
  end

  @impl Membrane.RTMP.MessageValidator
  def validate_publish(info, message) do
    case UserValidator.validate_rtmp(info.validator_pid, message.stream_key) do
      true ->
        {:ok, "Validate publish message successfull"}
      _ ->
        {:error, "Error in the publish validation"}
    end
  end

  @impl Membrane.RTMP.MessageValidator
  def validate_release_stream(info, message) do
    case UserValidator.validate_rtmp(info.validator_pid, message.stream_key) do
      true ->
        {:ok, "Validate release message successfull"}
      _ ->
        {:error, "Error in the release validation"}
    end
  end
end
