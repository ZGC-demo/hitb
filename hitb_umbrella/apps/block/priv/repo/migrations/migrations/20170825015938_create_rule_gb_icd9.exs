defmodule Drgwork.Repo.Migrations.CreateRuleGbIcd9 do
  use Ecto.Migration

  def change do
    create table(:rule_gb_icd9) do
      add :code, :string
      add :bj_code, :string
      add :name, :string
      add :adrg, {:array, :string}
      add :p_type, :integer
      add :org, :string
      add :year, :string
      add :version, :string
      add :plat, :string
      add :num_sum, :integer
      timestamps()
    end

  end
end
