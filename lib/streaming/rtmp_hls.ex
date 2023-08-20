defmodule Streaming.RTMP.HLS do
  require Logger
  use Membrane.Pipeline
  alias Membrane.RTMP.SourceBin
  alias Streaming.RTMP.Validator, as: RTMPValidator
  alias Streaming.User.Validator.Supervisor, as: UserValidatorSupervisor
  alias Streaming.User.Validator, as: UserValidator

  @impl true
  def handle_init(_context, socket: socket) do
    stream_uid = UUID.uuid4(:hex)

    structure = [
      child(:src, %SourceBin{
        socket: socket,
        validator: %RTMPValidator{stream_uid: stream_uid}
      })
      |> via_out(:audio)
      |> via_in(Pad.ref(:input, :audio),
        options: [encoding: :AAC, segment_duration: Membrane.Time.seconds(4)]
      )
      |> child(:sink, %Membrane.HTTPAdaptiveStream.SinkBin{
        manifest_module: Membrane.HTTPAdaptiveStream.HLS,
        target_window_duration: :infinity,
        persist?: false,
        storage: %Membrane.HTTPAdaptiveStream.Storages.FileStorage{
          directory: get_directory(stream_uid)
        }
      }),
      get_child(:src)
      |> via_out(:video)
      |> via_in(Pad.ref(:input, :video),
        options: [encoding: :H264, segment_duration: Membrane.Time.seconds(4)]
      )
      |> get_child(:sink)
    ]

    {[spec: structure], %{socket: socket, stream_uid: stream_uid}}
  end

  @impl true
  def handle_child_notification(
        {:socket_control_needed, _socket, _source} = notification,
        :src,
        _ctx,
        state
      ) do
    send(self(), notification)
    {[], state}
  end

  @impl true
  def handle_child_notification(
        {:stream_validation_success, _validation, {:error, reason}} = notification,
        _child,
        _ctx,
        state
      ) do
    Logger.error(reason)

    if File.exists?("output/#{state.stream_uid}") do
      case File.rm_rf("output/#{state.stream_uid}") do
        {:ok, _} ->
          Logger.info("Directory removed successfully.")

        {:error, reason, _} ->
          Logger.error("Failed to remove directory: #{reason}")
      end
    end

    Process.exit(Kernel.self(), :normal)

    {[], state}
  end

  def handle_child_notification(
        :end_of_stream,
        _child,
        _ctx,
        state
      ) do
    Logger.alert "End of stream!"
    GenServer.cast(state.user_pid, :end_of_stream)

    if File.exists?("output/#{state.stream_uid}") do
      case File.rm_rf("output/#{state.stream_uid}") do
        {:ok, _} ->
          Logger.info("Directory removed successfully.")

        {:error, reason, _} ->
          Logger.error("Failed to remove directory: #{reason}")
      end
    end

    Process.exit(Kernel.self(), :normal)
    {[], state}
  end

  def handle_child_notification(
        {:stream_validation_success, _validation, {:ok, _response, info}} = notification,
        _child,
        _ctx,
        state
      ) do
    {[], %{state | user_pid: info.user_pid}}
  end

  @impl true
  def handle_info({:socket_control_needed, socket, source} = notification, _ctx, state) do
    case SourceBin.pass_control(socket, source) do
      :ok ->
        :ok

      {:error, :not_owner} ->
        Process.send_after(self(), notification, 200)
    end

    {[], state}
  end

  def get_directory(stream_uid) do
    directory_path = "output/#{stream_uid}"

    case File.mkdir(directory_path) do
      :ok ->
        Logger.info("Directory created for stream #{stream_uid}")

      {:error, reason} ->
        Logger.error("Failed to create directory: #{reason}")
    end

    directory_path
  end
end
