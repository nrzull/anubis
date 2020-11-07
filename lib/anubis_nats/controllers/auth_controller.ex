defmodule AnubisNATS.AuthController do
  use Gnat.Server
  alias Anubis.AuthAction
  alias AnubisNATS.{Response, AuthLoginDTO}

  def request(%{topic: "auth.login", body: body}) do
    changeset = AuthLoginDTO.changeset(%AuthLoginDTO{}, body)

    with(
      true <- changeset.valid?,
      {:ok, token, _claims} <- AuthAction.login(Map.get(changeset, :changes))
    ) do
      Response.ok(token)
    else
      false ->
        Response.error(:invalid_data)

      {:error, reason} when is_atom(reason) ->
        Response.error(reason)
    end
  end
end
