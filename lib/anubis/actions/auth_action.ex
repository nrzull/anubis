defmodule Anubis.AuthAction do
  alias Anubis.Repo
  alias Anubis.Schemas.Account
  alias Anubis.{CryptService, JWTService}
  alias Ecto.Changeset

  import Ecto.Query
  require Logger

  def login(%{name: name, password: password, meta: meta}) do
    get_acc_query = from(a in Account, where: a.name == ^name, select: [:id, :password])

    with(
      {_, %Account{id: id, password: hashed_password}} <- {:get_account, Repo.one(get_acc_query)},
      {_, true} <- {:valid_password?, CryptService.valid?(password, hashed_password)},
      token_claims <- %{"id" => id, "meta" => meta},
      {_, {:ok, token, claims}} <- {:create_token, JWTService.generate_and_sign(token_claims)}
    ) do
      Logger.info(%{action: "AuthAction.login", name: name, meta: meta})
      {:ok, token, claims}
    else
      {:get_account, nil} ->
        {:error, :no_account}

      {:valid_password?, false} ->
        {:error, :invalid_password}

      {:create_token, {:error, _}} ->
        {:error, :cant_create_token}
    end
  end

  def register(%{name: name, password: password, meta: meta}) do
    exists_query = from(a in Account, where: a.name == ^name)

    with(
      {_, false} <- {:account_exists?, Repo.exists?(exists_query)},
      changeset <- Account.changeset(%Account{}, %{name: name, password: password}),
      {_, true} <- {:valid?, changeset.valid?},
      changeset <- Changeset.put_change(changeset, :password, CryptService.hash(password)),
      {_, {:ok, account}} <- {:create_account, Repo.insert(changeset)}
    ) do
      Logger.info(%{action: "AuthAction.register", name: name, meta: meta})
      {:ok, Map.get(account, :id)}
    else
      {:account_exists?, true} ->
        {:error, :account_already_exists}

      {:valid?, false} ->
        {:error, :not_valid}

      {:create_account, {:error, _changeset}} ->
        {:error, :cant_create_account}
    end
  end

  def verify_token(%{token: token, meta: meta, keys: keys}) do
    with(
      {_, {:ok, body}} <- {:valid?, JWTService.verify_and_validate(token)},
      {_, false} <- {:expired?, JWTService.expired?(body)},
      is_corrupted_payload <- %{token_meta: Map.get(body, "meta"), meta: meta, keys: keys},
      {_, nil} <- {:corrupted?, JWTService.check_for_corrupted_meta(is_corrupted_payload)}
    ) do
      {:ok, nil}
    else
      {:valid?, {:error, _}} ->
        {:error, :token_invalid}

      {:expired?, true} ->
        {:error, :token_expired}

      {:corrupted?, {token_meta, meta, keys}} ->
        {:error, :corrupted_meta, token_meta, meta, keys}

      {:error, :token_malformed} ->
        {:error, :token_invalid}
    end
  end
end
