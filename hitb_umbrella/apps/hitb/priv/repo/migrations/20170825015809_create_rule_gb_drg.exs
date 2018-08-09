defmodule Drgwork.Repo.Migrations.CreateRuleGbDrg do
  use Ecto.Migration

  def change do
    create table(:rule_gb_drg) do
      add :code, :string
      add :name, :string
      add :mdc, :string
      add :adrg, :string
      add :org, :string
      add :year, :string
      add :version, :string
      add :plat, :string
      add :num_sum, :integer
      timestamps()
    end

  end
end
