defmodule AnubisNATS.AuthLoginDTO do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @required_fields [:name, :password, :meta]

  embedded_schema do
    field(:name, :string)
    field(:password, :string)
    field(:meta, :map)
  end

  # TODO: add receiver type in meta (ex: receiver: :nats)
  def changeset(%__MODULE__{} = entity, <<_::binary>> = params) do
    entity
    |> cast(Jason.decode!(params), @required_fields)
    |> validate_required(@required_fields)
  end
end
