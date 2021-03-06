defmodule Block.Library.Repo.Migrations.CreateRuleDrg do
  use Ecto.Migration

  def change do
    create table(:rule_drg) do
      add :code, :string
      add :name, :string
      add :mdc, :string
      add :adrg, :string
      add :org, :string
      add :year, :string
      add :version, :string
      add :plat, :string
      add :previous_hash, :string
      add :hash, :string
      add :datetime, :string
      timestamps()
    end
    create unique_index(:rule_drg, [:hash])
  end
end
