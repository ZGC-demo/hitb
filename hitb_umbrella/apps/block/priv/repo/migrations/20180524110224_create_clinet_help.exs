defmodule Block.Edit.Repo.Migrations.CreateClinetHelp do
    use Ecto.Migration

    def change do
      create table(:clinet_help) do
        add :name, :string
        add :content, :string, size: 100000
        add :previous_hash, :string
        add :hash, :string
        add :datetime, :string
        timestamps()
      end
      create unique_index(:clinet_help, [:hash])
    end
  end
