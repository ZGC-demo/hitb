defmodule Block.Library.Repo.Migrations.CdaFile do
    use Ecto.Migration

    def change do
      create table(:cda_file) do
        add :username, :string #一级分类
        add :filename, :string #一级分类
        add :hash, :string
        add :previous_hash, :string
        add :datetime, :string
        timestamps()
      end
      create unique_index(:cda_file, [:hash])
    end
  end
