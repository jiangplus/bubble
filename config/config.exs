# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mime, :types, %{
  "text/event-stream" => ["event-stream"]
}

config :bubble, :redis_host, (System.get_env("REDIS_HOST") || "localhost")

config :joken, default_signer: (System.get_env("BUBBLE_SECRET") || "supersecret")

# Configures the endpoint
config :bubble, BubbleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3BXWIWCeC6GOPp07WB1hEpSpMm+woyuCvpmKiLjgUK4nW2sCXAHuSAT9ww9Rv+Lb",
  render_errors: [view: BubbleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bubble.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "Ud1dHKEn"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
