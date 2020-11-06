defmodule AnubisNATS.AuthController do
  use Gnat.Server
  alias Anubis.AuthAction
  alias AnubisNATS.{Response, AuthLoginDTO}

  def request(%{topic: "auth.login", body: body}) do
    changeset = AuthLoginDTO.changeset(%AuthLoginDTO{}, body)

    try do
      true = changeset.valid?
      {:ok, token, _claims} = AuthAction.login(Map.get(changeset, :changes))
      Response.ok(token)
    rescue
      _error ->
        Response.error(:invalid_data)
    end
  end
end
