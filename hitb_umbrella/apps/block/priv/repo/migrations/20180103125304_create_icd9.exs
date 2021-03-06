defmodule Block.Library.Repo.Migrations.CreateIcd9 do
  use Ecto.Migration

  def change do
    create table(:icd9) do
      add :code, :string
      add :codes, {:array, :string}
      add :name, :string
      add :icdcc, :string
      add :icdc, :string
      add :adrg, {:array, :string}
      add :drg, {:array, :string}
      add :p_type, :integer
      add :is_qy, :boolean, default: false
      add :year, :string
      add :previous_hash, :string
      add :hash, :string
      add :datetime, :string
      timestamps()
    end
    create unique_index(:icd9, [:hash])
  end
end
