# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :your_app,
  ecto_repos: [YourApp.Repo]

# Configures the endpoint
config :your_app, YourAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UxxjM17USvg5rNBBG4WnjUsehmsZ8bcbsnW9LUQ8oJV19BGaEls9jP1Wo5wpSbee",
  render_errors: [view: YourAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: YourApp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Entrance
config :entrance,
  repo: YourApp.Repo,
  security_module: Entrance.Auth.Bcrypt,
  user_module: YourApp.Accounts.User,
  default_authenticable_field: :email

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
