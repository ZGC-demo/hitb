defmodule Block.DataRecord do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.DataRecord


  schema "data_record" do
    field :type,    :string
    field :table,   :string
    field :data,    :string
    field :hash,    :string
    timestamps()
  end

  @doc false
  def changeset(%DataRecord{} = data_record, attrs) do
    data_record
    |> cast(attrs, [:type, :data, :hash, :table])
    |> validate_required([:type, :data, :hash, :table])
    |> unique_constraint(:hash)
  end
end
