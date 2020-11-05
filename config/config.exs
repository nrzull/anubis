use Mix.Config

config :anubis, ecto_repos: [Anubis.Repo]

import_config "#{Mix.env()}.exs"
