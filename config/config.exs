import Config

config :anubis, ecto_repos: [Anubis.Repo]

import_config "#{config_env()}.exs"
