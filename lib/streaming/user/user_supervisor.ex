defmodule Streaming.User.Supervisor do
  use DynamicSupervisor
  require Logger

  alias Streaming.Authenticated.User, as: AuthenticatedUserUser
  alias Streaming.Unauthenticated.User, as: UnauthenticatedUser 

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_unathenticated_user(websocket_pid) do
    DynamicSupervisor.start_child(__MODULE__, Supervisor.child_spec({UnauthenticatedUser, {websocket_pid}}, []))
  end

  def start_user(name, uid, websocket_pid) do
    DynamicSupervisor.start_child(__MODULE__, Supervisor.child_spec({AuthenticatedUserUser, {name, uid, websocket_pid}}, []))
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 10000, max_seconds: 1)
  end
end
