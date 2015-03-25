use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :extris_web, ExtrisWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :extris_web, ExtrisWeb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "extris_web_test",
  size: 1,
  max_overflow: false
