defmodule Streaming.Application do
  use Application
  alias Streaming.Router

  alias Membrane.RTMP.Source.TcpServer
  alias Streaming.Router.WebsocketRouter, as: WebSocketRouter
  alias Streaming.User.Supervisor, as: UserSupervisor

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

    cowboy_options = [
      port: 4000,
      dispatch: dispatch()
    ]

    children = [
      UserSupervisor,
      %{
        id: TcpServer,
        start: {TcpServer, :start_link, [tcp_server_options]}
      },
      {Plug.Cowboy, scheme: :http, plug: Router, options: cowboy_options},
      {Phoenix.PubSub, name: Streaming.LivestreamChat.PubSub}
    ]

    opts = [strategy: :one_for_one, name: Streaming.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch() do
    [
      {:_,
       [
         {"/ws/[...]", WebSocketRouter, []},
         {:_, Plug.Cowboy.Handler, {Router, []}}
       ]}
    ]
  end
end
