defmodule Streaming.Application do
  use Application
  alias Streaming.Router

  alias Membrane.RTMP.Source.TcpServer
  alias Streaming.User.Validator.Supervisor, as: UserValidatorSupervisor

  @port 9000
  @local_ip {127, 0, 0, 1}

  @impl true
  def start(_type, _args) do
    tcp_server_options = %TcpServer{
      port: @port,
      listen_options: [
        :binary,
        packet: :raw,
        active: false,
        ip: @local_ip
      ],
      socket_handler: fn socket ->
        {:ok, _sup, pid} = Streaming.RTMP.HLS.start_link(socket: socket)
        {:ok, pid}
      end
    }

    children = [
      UserValidatorSupervisor,
      %{
        id: TcpServer,
        start: {TcpServer, :start_link, [tcp_server_options]}
      },
     {Plug.Cowboy, scheme: :http, plug: Router, options: [port: 4001]}
    ]

    opts = [strategy: :one_for_one, name: Streaming.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
