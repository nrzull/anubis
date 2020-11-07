defmodule Anubis.AuthAction do
  alias Anubis.Repo
  alias Anubis.Schemas.Account
  alias Anubis.{CryptService, JWTService}
  alias Ecto.Changeset

  import Ecto.Query
  require Logger

  def login(%{name: name, password: password, meta: meta} = params) when is_map(params) do
    get_acc_query = from(a in Account, where: a.name == ^name, select: [:id, :password])

    with(
      {_, %Account{id: id, password: hashed_password}} <- {:get_account, Repo.one(get_acc_query)},
      {_, true} <- {:is_password_valid, CryptService.valid?(password, hashed_password)},
      token_claims <- Map.put(%{"id" => id}, "meta", meta),
      {_, {:ok, token, claims}} <- {:create_token, JWTService.generate_and_sign(token_claims)}
    ) do
      Logger.info(%{action: "AuthAction.login", name: name, meta: meta})
      {:ok, token, claims}
    else
      {:get_account, nil} ->
        {:error, :no_account}

      {:is_password_valid, false} ->
        {:error, :invalid_password}

      {:create_token, {:error, _}} ->
        {:error, :cant_create_token}
    end
  end

  def register(%{name: name, password: password, meta: meta} = params) when is_map(params) do
    exists_query = from(a in Account, where: a.name == ^name)

    with(
      {_, false} <- {:is_account_exists, Repo.exists?(exists_query)},
      changeset <- Account.changeset(%Account{}, params),
      {_, true} <- {:is_valid, changeset.valid?},
      changeset <- Changeset.put_change(changeset, :password, CryptService.hash(password)),
      {_, {:ok, account}} <- {:create_account, Repo.insert(changeset)}
    ) do
      Logger.info(%{action: "AuthAction.register", name: name, meta: meta})
      {:ok, Map.get(account, :id)}
    else
      {:is_account_exists, true} ->
        {:error, :account_already_exists}

      {:is_valid, false} ->
        {:error, :not_valid}

      {:create_account, {:error, _changeset}} ->
        {:error, :cant_create_account}
    end
  end
end
