defmodule Block.DataRecord do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.DataRecord


  schema "data_record" do
    field :type,    :string
    field :data,    :string
    field :hash,    :string
    timestamps()
  end

  @doc false
  def changeset(%DataRecord{} = data_record, attrs) do
    changeset = data_record
      |> cast(attrs, [:type, :data, :hash])
      |> validate_required([:host, :data, :hash])
    Block.create_data_record(changeset, "data_record")
    changeset
  end
end
