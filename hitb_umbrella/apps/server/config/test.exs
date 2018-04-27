use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :server, ServerWeb.Endpoint,
  http: [port: 4041],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :server, Server.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "server_test",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox
