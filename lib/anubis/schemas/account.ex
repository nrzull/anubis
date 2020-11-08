defmodule Anubis.Schemas.Account do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields [:password]
  @optional_fields [:name, :email, :phone]

  schema "account" do
    field(:name, :string)
    field(:password, :string)
    field(:email, :string)
    field(:phone, :string)

    timestamps()
  end

  def changeset_register(%__MODULE__{} = entity, %{} = params, required \\ [:name]) do
    cast_fields = Enum.dedup(required ++ @required_fields ++ @optional_fields)
    required_fields = Enum.dedup(required ++ @required_fields)

    value =
      entity
      |> cast(params, cast_fields)
      |> validate_required(required_fields)

    Map.get(value, :changes)
    |> Map.keys()
    |> Enum.filter(&(&1 in cast_fields))
    |> Enum.reduce(value, &validate_for(&2, &1))
  end

  def validate_for(changeset, :name) do
    changeset
    |> validate_length(:name, min: 2, max: 32)
  end

  def validate_for(changeset, :password) do
    changeset
    |> validate_length(:password, min: 8, max: 256)
  end

  def validate_for(changeset, :email) do
    changeset
    |> validate_length(:email, min: 4, max: 128)
  end

  def validate_for(changeset, _) do
    changeset
  end
end
