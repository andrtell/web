import Config

# Cache manifest

config :tell, TellWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Logflare

config :logger,
  level: :info,
  backends: [LogflareLogger.HttpBackend]

# Host / SSL

config :tell, TellWeb.Endpoint, force_ssl: []
