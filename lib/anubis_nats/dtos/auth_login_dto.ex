defmodule AnubisNATS.AuthLoginDTO do
  use Ecto.Schema
  import Ecto.Changeset
  alias Anubis.Schemas.Account

  @primary_key false
  @required_fields [:password, :meta]
  @optional_fields [:name, :email, :phone]

  embedded_schema do
    field(:name, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:password, :string)
    field(:meta, :map)
  end

  def changeset(%__MODULE__{} = entity, <<_::binary>> = params, required \\ [:name]) do
    cast_fields = Enum.dedup(required ++ @required_fields ++ @optional_fields)
    required_fields = Enum.dedup(required ++ @required_fields)

    value =
      entity
      |> cast(Jason.decode!(params), cast_fields)
      |> validate_required(required_fields)

    Map.get(value, :changes)
    |> Map.keys()
    |> Enum.filter(&(&1 in cast_fields))
    |> Enum.reduce(value, &Account.validate_for(&2, &1))
  end
end
