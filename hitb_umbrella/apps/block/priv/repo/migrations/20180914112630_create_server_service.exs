defmodule Block.Repo.Migrations.CreateServerService do
  use Ecto.Migration

  def change do
    create table(:server_service) do
      add :host,    :string
      add :port,    :string
      add :info,    :string
      add :version, :string
      add :connect, :boolean, default: false
      timestamps()
    end
    # create unique_index(:stat_cda, [:items])
  end
end
