defmodule Block.Stat.Repo.Migrations.CreateClientSaveStat do
  use Ecto.Migration

  def change do
    create table(:client_save_stat) do
      add :username, :string #创建用户
      add :filename, :string #文件名
      add :data, :string, size: 100000 #数据
      add :previous_hash, :string
      add :hash, :string
      add :datetime, :string
      timestamps()
    end
    create unique_index(:client_save_stat, [:hash])
  end
end
