defmodule AnubisNATS.AuthController do
  use Gnat.Server
  alias Anubis.AuthAction
  alias AnubisNATS.{Response, AuthLoginDTO, AuthRegisterDTO, AuthVerifyTokenDTO}

  def request(%{topic: "auth.login", body: body}) do
    changeset = AuthLoginDTO.changeset(%AuthLoginDTO{}, body)

    with(
      true <- changeset.valid?,
      {:ok, token, _claims} <- AuthAction.login(Map.get(changeset, :changes))
    ) do
      Response.ok(token)
    else
      false ->
        Response.error(%{kind: :invalid_data})

      {:error, reason} when is_atom(reason) ->
        Response.error(%{kind: reason})
    end
  end

  def request(%{topic: "auth.register", body: body}) do
    changeset = AuthRegisterDTO.changeset(%AuthRegisterDTO{}, body)

    with(
      true <- changeset.valid?,
      {:ok, <<_::binary>> = id} <- AuthAction.register(Map.get(changeset, :changes))
    ) do
      Response.ok(id)
    else
      false ->
        Response.error(%{kind: :invalid_data})

      {:error, reason} when is_atom(reason) ->
        Response.error(%{kind: reason})
    end
  end

  def request(%{topic: "auth.verify_token", body: body}) do
    changeset = AuthVerifyTokenDTO.changeset(%AuthVerifyTokenDTO{}, body)

    with(
      true <- changeset.valid?,
      {:ok, _} <- AuthAction.verify_token(Map.get(changeset, :changes))
    ) do
      Response.ok()
    else
      false ->
        Response.error(%{kind: :invalid_data})

      {:error, :corrupted_meta, %{} = token_meta, %{} = meta, keys} ->
        Response.error(%{kind: :corrupted_meta, meta: meta, token_meta: token_meta, keys: keys})

      {:error, :token_expired} ->
        Response.error(%{kind: :token_expired})

      {:error, reason} when is_atom(reason) ->
        Response.error(%{kind: reason})
    end
  end
end
