import Config

config :anubis, Anubis.Repo,
  database: "anubis_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :anubis, Anubis.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :anubis,
  host: '127.0.0.1',
  port: 4222

config :joken, default_signer: "super_password"

config :bcrypt_elixir, :log_rounds, 4

import_config "#{config_env()}.secret.exs"
