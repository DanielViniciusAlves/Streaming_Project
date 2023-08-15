defmodule Twitch.User.Validator do
  use GenServer, restart: :temporary
  require Logger

  def start_link(opts, args) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(rtmp_pid) do
    {:ok, %{rtmp_pid: rtmp_pid, user_pid: nil, user_key: nil, stream_uid: nil}}
  end

  # Genserver API 
  def validate_rtmp(pid, stream_key) do
    GenServer.call(pid, {:validate_rtmp, stream_key})
  end

  def get_directory(pid) do
    GenServer.call(pid, :get_directory)
  end

  # Genserver Implementation
  def handle_call({:validate_rtmp, rtmp_key}, _from, state) do
    [user_uid | stream_key]= String.split(rtmp_key, "_")
    case stream_validation(user_uid, stream_key, state) do
      :error ->

        Logger.error("Stream validation Failed")
        if File.exists?("output/#{state.stream_uid}") do
          case File.rm_rf("output/#{state.stream_uid}") do
            {:ok, _} ->
              Logger.info "Directory removed successfully."

            {:error, reason, _} ->
              Logger.error "Failed to remove directory: #{reason}"
          end
        end

        {:stop, {:shutdown, "Stream validation failed"}, state}

      {:ok, info} ->
        {:reply, :ok, info}
    end
  end

  def handle_call(:get_directory, _from, state) do
    stream_uid = UUID.uuid4(:hex)

    directory_path = "output/#{stream_uid}" 
    case File.mkdir(directory_path) do
      :ok ->
        Logger.info "Directory created for stream #{stream_uid}"

      {:error, reason} ->
        Logger.error "Failed to create directory: #{reason}"
    end

    {:reply, directory_path, %{state | stream_uid: stream_uid}}
  end

  # Utility funtions
  def stream_validation(user_uid, stream_key, state) do
    case state.user_key do
      nil ->
        case Swarm.whereis_name(user_uid) do
         :undefined ->
          Logger.error "User UID #{user_uid} not found!"
          :error

        pid -> 
          user_stream_key = UserServer.get_stream_key(pid)
          cond do
            user_stream_key == stream_key ->
              UserServer.defines_stream_uid(pid, state.stream_uid)
              {:ok, %{state | user_key: user_stream_key}}
            true ->
              Logger.error "Stream Key not valid!"
              :error
          end
        end

      user_stream_key ->
        cond do
          user_stream_key == stream_key ->
            {:ok, state}
          true ->
            Logger.error "Stream Key not valid!"
            :error
        end
    end
  end
end
