import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_streaming, PhoenixStreaming.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "bXriiaDFR+Umo4f7Bsq96fcrCuV7mviLnrM6CCOxW4dniuc0AiWN3i96bzkx+sc5",
  server: false
