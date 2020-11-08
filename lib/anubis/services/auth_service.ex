defmodule Anubis.AuthService do
  alias Anubis.Repo
  alias Anubis.Schemas.Account
  alias Anubis.{CryptService, JWTService}
  alias Ecto.Changeset

  import Ecto.Query
  require Logger

  @available_login_interfaces [:name, :email, :phone]
  @available_register_interfaces [:name, :email, :phone]

  def is_available_with(:login, interface) when is_bitstring(interface) do
    interface in Enum.map(@available_login_interfaces, &Atom.to_string(&1))
  end

  def is_available_with(:register, interface) when is_bitstring(interface) do
    interface in Enum.map(@available_register_interfaces, &Atom.to_string(&1))
  end

  def login(:name, %{name: value, password: password, meta: meta}) do
    q = from(a in Account, where: a.name == ^value, select: [:id, :password])
    do_login(:name, value, q, %{name: value, password: password, meta: meta})
  end

  def login(:email, %{email: value, password: password, meta: meta}) do
    q = from(a in Account, where: a.email == ^value, select: [:id, :password])
    do_login(:email, value, q, %{email: value, password: password, meta: meta})
  end

  def login(:phone, %{phone: value, password: password, meta: meta}) do
    q = from(a in Account, where: a.phone == ^value, select: [:id, :password])
    do_login(:phone, value, q, %{phone: value, password: password, meta: meta})
  end

  defp do_login(atom, value, get_acc_query, %{password: password, meta: meta}) do
    with(
      {_, %Account{id: id, password: hashed_password}} <- {:get_account, Repo.one(get_acc_query)},
      {_, true} <- {:valid_password?, CryptService.valid?(password, hashed_password)},
      token_claims <- JWTService.gen_claims(%{id: id, meta: meta}),
      {_, {:ok, token, claims}} <- {:create_token, JWTService.generate_and_sign(token_claims)}
    ) do
      Logger.info([{:action, "AuthService.login"}, {atom, value}, {:meta, meta}])
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

  def register(:name, %{name: value, password: password, meta: meta}) do
    q = from(a in Account, where: a.name == ^value)
    do_register(:name, value, q, %{name: value, password: password, meta: meta})
  end

  def register(:email, %{email: value, password: password, meta: meta}) do
    q = from(a in Account, where: a.email == ^value)
    do_register(:email, value, q, %{email: value, password: password, meta: meta})
  end

  def register(:phone, %{phone: value, password: password, meta: meta}) do
    q = from(a in Account, where: a.phone == ^value)
    do_register(:phone, value, q, %{phone: value, password: password, meta: meta})
  end

  defp do_register(atom, value, exists_query, %{password: password, meta: meta} = params) do
    with(
      {_, false} <- {:account_exists?, Repo.exists?(exists_query)},
      changeset <- Account.changeset_register(%Account{}, params),
      {_, true} <- {:valid?, changeset.valid?},
      changeset <- Changeset.put_change(changeset, :password, CryptService.hash(password)),
      {_, {:ok, account}} <- {:create_account, Repo.insert(changeset)}
    ) do
      Logger.info([{:action, "AuthService.register"}, {atom, value}, {:meta, meta}])
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
    prepare_is_corrupted_payload = fn body, meta, keys ->
      %{token_meta: Map.get(body, "meta"), meta: meta, keys: keys}
    end

    with(
      {_, {:ok, body}} <- {:valid?, JWTService.verify_and_validate(token)},
      {_, false, _} <- {:expired?, JWTService.expired?(body), body},
      is_corrupted_payload <- prepare_is_corrupted_payload.(body, meta, keys),
      {_, nil} <- {:corrupted?, JWTService.check_for_corrupted_meta(is_corrupted_payload)}
    ) do
      {:ok, nil}
    else
      {:valid?, {:error, _}} ->
        {:error, :token_invalid}

      {:expired?, true, body} ->
        is_corrupted_payload = prepare_is_corrupted_payload.(body, meta, keys)

        case JWTService.check_for_corrupted_meta(is_corrupted_payload) do
          nil ->
            JWTService.refresh_token(is_corrupted_payload)

          _ ->
            {:error, :token_expired}
        end

      {:corrupted?, {token_meta, meta, keys}} ->
        {:error, :corrupted_meta, token_meta, meta, keys}

      {:error, :token_malformed} ->
        {:error, :token_invalid}
    end
  end
end
