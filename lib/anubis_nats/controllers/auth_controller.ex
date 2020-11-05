defmodule AnubisNATS.AuthController do
  use Gnat.Server
  alias AnubisNATS.AuthLoginDTO

  def request(%{topic: "auth.login", body: body}) do
    changeset = AuthLoginDTO.changeset(%AuthLoginDTO{}, body)
    {:reply, Atom.to_string(changeset.valid?)}
  end
end
