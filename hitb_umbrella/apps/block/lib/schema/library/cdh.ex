defmodule Block.Library.Cdh do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Library.Cdh


  schema "cdh" do
    field :key, :string
    field :value, :string
    field :previous_hash, :string
    field :hash, :string
    timestamps()
  end

  @doc false
  def changeset(%Cdh{} = cdh, attrs) do
    changeset = cdh
      |> cast(attrs, [:key, :value, :previous_hash, :hash])
      |> validate_required([:key, :value, :previous_hash, :hash])
      |> unique_constraint(:key)
    Block.create_data_record(cdh, changeset, "cdh")
    changeset
  end
end
