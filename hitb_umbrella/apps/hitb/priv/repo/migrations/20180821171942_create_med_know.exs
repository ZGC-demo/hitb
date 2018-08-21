defmodule Hitb.Library.Repo.Migrations.MdeKnow do
  use Ecto.Migration

  def change do
    create table(:mde_know) do
      add :name, :string
      add :en_name, :string
      add :desc, :string, size: 10485760
      add :keywords, {:array, :string}, size: 10485760
      add :create_user, :string
      add :update_user, :string
      timestamps()
    end
    # create unique_index(:stat_cda, [:items])
  end
end
