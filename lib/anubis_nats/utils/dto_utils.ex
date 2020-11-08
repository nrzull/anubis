defmodule AnubisNATS.DTOUtils do
  alias Anubis.AuthService
  import Ecto.Changeset

  def validate_via(changeset, :login, error) when is_bitstring(error) do
    do_validate_via(changeset, :login, error)
  end

  def validate_via(changeset, :register, error) when is_bitstring(error) do
    do_validate_via(changeset, :register, error)
  end

  defp do_validate_via(changeset, interface, error) do
    changeset
    |> validate_required([:via])
    |> validate_length(:via, min: 1, max: 16)
    |> validate_change(:via, fn :via, value ->
      case AuthService.is_available_with(interface, value) do
        false -> [via: error]
        true -> []
      end
    end)
  end
end
