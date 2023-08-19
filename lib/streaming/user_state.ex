defmodule Streaming.UserState do
  defstruct [
    :websocket_pid,
    :user_uid,
    :username,
    :live_status,
    :stream_uid,
    :stream_key,
    :stream_pid
  ]
end
