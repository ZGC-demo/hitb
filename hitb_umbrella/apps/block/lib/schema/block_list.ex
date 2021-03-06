defmodule Block.BlockList do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.BlockList


  schema "block_list" do
    field :index,          :integer
    field :previous_hash,  :string
    field :timestamp,      :integer
    field :data,           :string
    field :hash,           :string
    field :generateAdress, :string
    timestamps()
  end

  @doc false
  def changeset(%BlockList{} = block_list, attrs, _type) do
    changeset = block_list
    |> cast(attrs, [:index, :previous_hash, :timestamp, :data, :hash, :generateAdress])
    |> validate_required([:index, :previous_hash, :timestamp, :data, :hash, :generateAdress])
    |> unique_constraint(:index)
    # if(type == "insert")do
      # Block.create_data_record(block_list, changeset, "block_list")
    # end
    changeset
  end
end
