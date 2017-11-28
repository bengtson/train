# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :train, TrainWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bTAqZMdIPcN2HNk/LDKtRFrYdgQtjwin4pYXMASDFyk82RaE4SNdvVfoIb0Oa3Ep",
  render_errors: [view: TrainWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Train.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :train, :piphone,
  port: 5006

  # Status server configuration
config :train, :status_server,
  host: '10.0.1.212', port: 21200, start: :true

config :train, TrainWeb.Endpoint,
  http: [port: 4408],
  debug_errors: true,
  code_reloader: false,
  check_origin: false
#  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
#                    cd: Path.expand("../assets", __DIR__)]]
