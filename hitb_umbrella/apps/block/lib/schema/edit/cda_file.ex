defmodule Block.Edit.CdaFile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Edit.CdaFile


  schema "cda_file" do
    field :username, :string
    field :filename, :string
    field :hash, :string
    field :previous_hash, :string
    field :datetime, :string
    timestamps()
  end

  @doc false
  def changeset(%CdaFile{} = cda_file, attrs) do
    cda_file
    |> cast(Block.merge_time(attrs), [:username, :filename, :hash, :previous_hash, :datetime])
    |> validate_required([:username, :filename, :hash, :previous_hash, :datetime])
    |> unique_constraint(:hash)
  end


end
