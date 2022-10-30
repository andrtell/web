import Config

# Start the phoenix server if environment is set and running in a release

if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :tell, TellWeb.Endpoint, server: true
end

if config_env() == :prod do
  # Env

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  ssl_key_path =
    System.get_env("SSL_KEY_PATH") ||
      raise """
      environment variable SSL_KEY_PATH is missing.
      """

  logflare_api_key =
    System.get_env("LOGFLARE_API_KEY") ||
      raise """
      environment variable LOGFLARE_API_KEY is missing.
      """

  logflare_source_id =
    System.get_env("LOGFLARE_SOURCE_ID") ||
      raise """
      environment variable LOGFLARE_SOURCE_ID is missing.
      """

  ssl_cert_path =
    System.get_env("SSL_CERT_PATH") ||
      raise """
      environment variable SSL_CERT_PATH is missing.
      """

  # Logflare

  config :logflare_logger_backend,
    url: "https://api.logflare.app",
    level: :info,
    api_key: logflare_api_key,
    source_id: logflare_source_id,
    flush_interval: 1_000,
    max_batch_size: 50,
    metadata: :all

  # Host / SSL

  config :tell, TellWeb.Endpoint,
    url: [scheme: "https", host: "tell.nu", port: 443],
    http: [port: 8000],
    https: [
      port: 4430,
      cipher_suite: :strong,
      keyfile: ssl_key_path,
      certfile: ssl_cert_path
    ],
    secret_key_base: secret_key_base

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :tell, Tell.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
