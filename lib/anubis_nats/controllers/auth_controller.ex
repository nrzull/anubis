defmodule AnubisNATS.AuthController do
  use Gnat.Server
  alias AnubisNATS.AuthLoginDTO
  alias AnubisNATS.Response

  def request(%{topic: "auth.login", body: body}) do
    changeset = AuthLoginDTO.changeset(%AuthLoginDTO{}, body)

    case changeset.valid? do
      true -> {:reply, Response.ok(changeset.valid?)}
      false -> {:reply, Response.error(changeset.valid?)}
    end
  end
end
