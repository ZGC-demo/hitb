defmodule Block.Server.Repo.Migrations.CreateChatRecord do
  use Ecto.Migration

  def change do
    create table(:chat_record) do
      add :room, :string
      add :date, :string
      add :record_string, :string, size: 1000000
      add :record_array, {:array, :string}, size: 1000000
      add :previous_hash, :string
      add :hash, :string
      add :datetime, :string
      timestamps()
    end
    create unique_index(:chat_record, [:hash])
  end
end
