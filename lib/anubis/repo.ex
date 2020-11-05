defmodule Anubis.Repo do
  use Ecto.Repo,
    otp_app: :anubis,
    adapter: Ecto.Adapters.Postgres
end
