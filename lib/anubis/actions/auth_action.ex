defmodule Anubis.AuthAction do
  alias Anubis.Repo
  alias Anubis.Schemas.Account
  alias Anubis.CryptService
  alias Ecto.Changeset
  import Ecto.Query
  require Logger

  def login(%{name: name, password: password, meta: meta} = params) when is_map(params) do
    %Account{id: id, password: hashed_password} =
      Repo.one!(from(a in Account, where: a.name == ^name, select: [:id, :password]))

    true = CryptService.valid?(password, hashed_password)

    {:ok, token, claims} = Anubis.JWTService.generate_and_sign(%{"id" => id})

    Logger.info(Map.merge(meta, %{name: name, action: "AuthAction.login"}))

    {:ok, token, claims}
  end

  def register(%{name: name, password: password, meta: meta} = params) when is_map(params) do
    false = Repo.exists?(from(a in Account, where: a.name == ^name))

    changeset = Account.changeset(%Account{}, params)

    true = changeset.valid?

    changeset = Changeset.put_change(changeset, :password, CryptService.hash(password))

    account = Repo.insert!(changeset)

    Logger.info(Map.merge(meta, %{name: name, action: "AuthAction.register"}))

    {:ok, Map.get(account, :id)}
  end
end
