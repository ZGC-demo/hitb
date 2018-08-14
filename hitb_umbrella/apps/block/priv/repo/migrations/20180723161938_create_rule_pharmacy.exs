defmodule Hitb.Library.Repo.Migrations.RulePharmacy do
    use Ecto.Migration

    def change do
      create table(:rule_pharmacy) do
        add :pharmacy, :string, size: 1000000 #用药
        add :icd10_a, {:array, :string} #icd10_a
        add :symptoms, {:array, :string} #主诉 症状
        add :create_user, :string
        add :update_user, :string
        timestamps()
      end
      # create unique_index(:stat_cda, [:items])
    end
  end
