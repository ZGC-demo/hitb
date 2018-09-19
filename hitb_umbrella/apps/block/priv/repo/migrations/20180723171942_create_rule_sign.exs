defmodule Block.Library.Repo.Migrations.RuleSign do
  use Ecto.Migration

  def change do
    create table(:rule_sign) do
      add :sign, :string
      add :icd9_a, {:array, :string}
      add :icd10_a, {:array, :string}
      add :pharmacys, {:array, :string}
      add :create_user, :string
      add :update_user, :string
      add :previous_hash, :string
      add :hash, :string
      timestamps()
    end
    create unique_index(:rule_sign, [:hash])
  end
end
