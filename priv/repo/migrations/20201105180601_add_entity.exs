defmodule Anubis.Repo.Migrations.AddEntity do
  use Ecto.Migration

  def change do
    create table(:account, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, size: 64)
      add(:password, :string, size: 256)

      timestamps()
    end
  end
end
