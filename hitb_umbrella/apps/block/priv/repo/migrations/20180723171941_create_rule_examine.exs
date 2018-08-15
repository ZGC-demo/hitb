defmodule Hitb.Library.Repo.Migrations.RuleExamine do
  use Ecto.Migration

  def change do
    create table(:rule_examine) do
      add :examine, :string
      add :icd10_a, {:array, :string}
      add :icd10_b, {:array, :string}
      add :create_user, :string
      add :update_user, :string
      add :previous_hash, :string
      add :hash, :string
      timestamps()
    end
    # create unique_index(:stat_cda, [:items])
  end
end
