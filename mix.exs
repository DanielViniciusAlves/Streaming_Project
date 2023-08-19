defmodule Streaming.MixProject do
  use Mix.Project

  def project do
    [
      app: :streaming,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Streaming.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.14"},
      {:plug_cowboy, "~> 2.0"},
      {:joken, "~> 2.5"},
      {:jason, "~> 1.3"},
      {:membrane_core, "~> 0.12.7"},
      {:membrane_rtmp_plugin, "~> 0.14.0"},
      {:membrane_http_adaptive_stream_plugin, "~> 0.15.0"},
      {:corsica, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:swarm, "~> 3.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:cowboy, "~> 2.9"}
    ]
  end
end
