defmodule AnubisNATS.AuthVerifyTokenDTO do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @required_fields [:token, :meta, :keys]

  embedded_schema do
    field(:token, :string)
    field(:meta, :map)
    field(:keys, {:array, :string})
  end

  def changeset(%__MODULE__{} = entity, <<_::binary>> = params) do
    entity
    |> cast(Jason.decode!(params), @required_fields)
    |> validate_required(@required_fields)
  end
end
