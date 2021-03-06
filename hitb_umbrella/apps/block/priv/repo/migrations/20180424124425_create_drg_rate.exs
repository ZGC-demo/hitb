defmodule Block.Library.Repo.Migrations.CreateDrgRate do
  use Ecto.Migration

  def change do
    create table(:drg_rate) do
      add :drg, :string
      add :name, :string
      add :rate, :float
      add :type, :string
      add :previous_hash, :string
      add :hash, :string
      add :datetime, :string
      timestamps()
    end
    create unique_index(:drg_rate, [:hash])
  end
end
