defmodule Twitch.User.Validator.Supervisor do
  use DynamicSupervisor
  require Logger

  alias Twitch.User.Validator

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_validator(rtmp_pid) do
    DynamicSupervisor.start_child(__MODULE__, Supervisor.child_spec({Validator, {rtmp_pid}}, []))
  end

  def spawn_client() do
    {:ok, _pid} = Validator.start_link({})
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 10000, max_seconds: 1)
  end
end

