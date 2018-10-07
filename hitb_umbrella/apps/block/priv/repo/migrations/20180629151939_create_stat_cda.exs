defmodule Block.Stat.Repo.Migrations.StatCda do
    use Ecto.Migration

    def change do
      create table(:stat_cda) do
        add :items, :string, size: 1000000
        add :num, :integer
        add :previous_hash, :string
        add :hash, :string
        add :patient_id, {:array, :string}
        add :datetime, :string
        timestamps()
      end
      create unique_index(:stat_cda, [:hash])

    end
  end
