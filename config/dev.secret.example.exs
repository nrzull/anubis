use Mix.Config

config :anubis, Anubis.Repo,
  database: "anubis_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :anubis,
  host: '127.0.0.1',
  port: 4222
