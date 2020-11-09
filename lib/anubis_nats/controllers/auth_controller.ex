defmodule AnubisNATS.AuthController do
  use Gnat.Server
  alias Anubis.{AuthService, ChangesetService}
  alias AnubisNATS.{Response, AuthLoginDTO, AuthRegisterDTO, AuthVerifyTokenDTO}

  def request(%{topic: "auth.login", body: body}) do
    changeset = AuthLoginDTO.changeset(%AuthLoginDTO{}, body)

    with(
      true <- changeset.valid?,
      via <- String.to_atom(Ecto.Changeset.get_change(changeset, :via)),
      {:ok, token, claims} <- AuthService.login(via, Map.get(changeset, :changes))
    ) do
      Response.ok(%{kind: :new_token, token: token, claims: claims})
    else
      false ->
        Response.error(%{kind: :invalid_data, errors: ChangesetService.build_error_map(changeset)})

      {:error, reason} when is_atom(reason) ->
        Response.error(%{kind: reason})

      {:error, reason, errors} when is_atom(reason) ->
        Response.error(%{kind: reason, errors: errors})
    end
  end

  def request(%{topic: "auth.register", body: body}) do
    changeset = AuthRegisterDTO.changeset(%AuthRegisterDTO{}, body)

    with(
      true <- changeset.valid?,
      via <- String.to_atom(Ecto.Changeset.get_change(changeset, :via)),
      {:ok, <<_::binary>> = id} <- AuthService.register(via, Map.get(changeset, :changes))
    ) do
      Response.ok(%{account_id: id})
    else
      false ->
        Response.error(%{kind: :invalid_data, errors: ChangesetService.build_error_map(changeset)})

      {:error, reason} when is_atom(reason) ->
        Response.error(%{kind: reason})

      {:error, reason, errors} when is_atom(reason) ->
        Response.error(%{kind: reason, errors: errors})
    end
  end

  def request(%{topic: "auth.verify_token", body: body}) do
    changeset = AuthVerifyTokenDTO.changeset(%AuthVerifyTokenDTO{}, body)

    with(
      true <- changeset.valid?,
      {:ok, _} <- AuthService.verify_token(Map.get(changeset, :changes))
    ) do
      Response.ok(%{})
    else
      {:ok, token, claims} ->
        Response.ok(%{kind: :new_token, token: token, claims: claims})

      false ->
        Response.error(%{kind: :invalid_data, errors: ChangesetService.build_error_map(changeset)})

      {:error, :corrupted_meta, %{} = token_meta, %{} = meta, keys} ->
        Response.error(%{kind: :corrupted_meta, meta: meta, token_meta: token_meta, keys: keys})

      {:error, :token_expired} ->
        Response.error(%{kind: :token_expired})

      {:error, reason} when is_atom(reason) ->
        Response.error(%{kind: reason})

      {:error, reason, errors} when is_atom(reason) ->
        Response.error(%{kind: reason, errors: errors})
    end
  end
end
