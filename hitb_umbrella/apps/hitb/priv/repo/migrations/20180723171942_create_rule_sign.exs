defmodule Hitb.Library.Repo.Migrations.RuleSign do
  use Ecto.Migration

  def change do
    create table(:rule_sign) do
      add :sign, :string
      add :icd9_a, {:array, :string}
      add :icd10_a, {:array, :string}
      add :pharmacys, {:array, :string}
      add :create_user, :string
      add :update_user, :string
      timestamps()
    end
    # create unique_index(:stat_cda, [:items])
  end
end
