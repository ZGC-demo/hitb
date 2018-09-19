defmodule Block.Library.Repo.Migrations.RuleSymptom do
    use Ecto.Migration

    def change do
      create table(:rule_symptom) do
        add :symptom, :string, size: 1000000 #主诉 症状
        add :icd9_a, {:array, :string} #icd9_a
        add :icd10_a, {:array, :string} #icd10_a
        add :pharmacys, {:array, :string} #用药
        add :create_user, :string
        add :update_user, :string
        add :previous_hash, :string
        add :hash, :string
        timestamps()
      end
      create unique_index(:rule_symptom, [:hash])
    end
  end
