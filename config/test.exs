import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :todo_api, TodoApi.Repo,
  url: "postgres://postgres:postgres@db/todo_api_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  timeout: :infinity

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :todo_api, TodoApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "N7sa6xc2+6emg9roXYAWNZiyt2c72MaEy38MDl8TksicYEFehfUGWbJsr33trRaI",
  server: false

# In test we don't send emails
config :todo_api, TodoApi.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
