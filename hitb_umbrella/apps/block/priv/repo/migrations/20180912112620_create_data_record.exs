defmodule Block.Repo.Migrations.CreateDataRecord do
  use Ecto.Migration

  def change do
    create table(:data_record) do
      add :type,    :string
      add :table,   :string
      add :data,    :string, size: 10485760
      add :hash,    :string
      add :datetime, :string
      timestamps()
    end
    create unique_index(:data_record, [:hash])
  end
end
