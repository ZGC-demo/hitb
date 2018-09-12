defmodule Hitb.Repo.Migrations.CreateDataRecord do
  use Ecto.Migration

  def change do
    create table(:data_record) do
      add :type,    :string
      add :data,    :string
      add :hash,    :string
      timestamps()
    end
    # create unique_index(:stat_cda, [:items])
  end
end
