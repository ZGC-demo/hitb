defmodule Hitb.Library.Repo.Migrations.RuleSign do
  use Ecto.Migration

  def change do
    create table(:rule_sign) do
      add :symptom, :string
      add :icd9_a, {:array, :string}
      add :icd10_a, {:array, :string}
      add :pharmacy, {:array, :string}
      timestamps()
    end
    # create unique_index(:stat_cda, [:items])
  end
end
