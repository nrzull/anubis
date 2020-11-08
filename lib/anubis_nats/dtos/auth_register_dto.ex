defmodule AnubisNATS.AuthRegisterDTO do
  use Ecto.Schema
  import Ecto.Changeset
  alias Anubis.Schemas.Account
  alias AnubisNATS.DTOUtils

  @primary_key false
  @required_fields [:via, :password, :meta]
  @optional_fields [:name, :email, :phone]

  embedded_schema do
    field(:name, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:via, :string)
    field(:password, :string)
    field(:meta, :map)
  end

  def changeset(%__MODULE__{} = entity, <<_::binary>> = params) do
    cast_fields = @required_fields ++ @optional_fields
    required_fields = @required_fields

    value =
      entity
      |> cast(Jason.decode!(params), cast_fields)
      |> DTOUtils.validate_via(:register, "invalid register interface")

    case value.valid? do
      false ->
        value

      true ->
        via = String.to_atom(Ecto.Changeset.get_change(value, :via))

        value = validate_required(value, [via | required_fields])

        Map.get(value, :changes)
        |> Map.keys()
        |> Enum.filter(&(&1 in cast_fields))
        |> Enum.reduce(value, &Account.validate_for(&2, &1))
    end
  end
end
