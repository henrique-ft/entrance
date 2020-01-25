use Mix.Config

# Configure your database
config :your_app, YourApp.Repo,
  username: "postgres",
  password: "postgres",
  database: "your_app_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :your_app, YourAppWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
