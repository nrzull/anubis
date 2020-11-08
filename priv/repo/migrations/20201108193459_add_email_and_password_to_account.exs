defmodule Anubis.Repo.Migrations.AddEmailAndPasswordToAccount do
  use Ecto.Migration

  def change do
    alter table(:account) do
      add(:email, :string, size: 128)
      add(:phone, :string, size: 32)
    end
  end
end
