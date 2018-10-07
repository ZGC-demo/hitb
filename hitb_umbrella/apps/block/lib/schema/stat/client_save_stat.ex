defmodule Block.Stat.ClientSaveStat do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Stat.ClientSaveStat


  schema "client_save_stat" do
    field :username, :string #创建用户
    field :filename, :string #文件名
    field :data, :string #数据
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end

  @doc false
  def changeset(%ClientSaveStat{} = client_save_stat, attrs) do
    changeset = client_save_stat
      |> cast(attrs, [:username, :filename, :data, :previous_hash, :hash, :datetime])
      |> validate_required([:username, :filename, :data, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(client_save_stat, changeset, "client_save_stat")
    changeset
  end
end
