defmodule Anubis.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # alias Anubis.Repo

      # import Ecto
      # import Ecto.Query
      import Anubis.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Anubis.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Anubis.Repo, {:shared, self()})
    end

    :ok
  end
end
