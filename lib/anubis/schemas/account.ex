defmodule Anubis.Schemas.Account do
  import Ecto.Changeset, only: [cast: 3, validate_required: 2]
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields [:name, :password]
  @optional_fields []

  schema "account" do
    field(:name, :string)
    field(:password, :string)

    timestamps()
  end

  def changeset(%__MODULE__{} = entity, %{} = params) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
