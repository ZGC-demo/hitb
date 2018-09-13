defmodule Block.Library.Mdc do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Library.Mdc

  schema "mdc" do
    field :code, :string
    field :name, :string
    field :mdc, :string
    # field :icd9_aa, {:array, :string}
    field :is_p, :boolean, default: false
    field :gender, :string
    field :year, :string
    field :previous_hash, :string
    field :hash, :string
    timestamps()
  end

  def changeset(%Mdc{} = mdc, attrs) do
    changeset = mdc
      |> cast(attrs, [:code, :name, :mdc, :gender, :previous_hash, :hash])
      |> validate_required([:code, :name, :mdc, :gender, :previous_hash, :hash])
    Block.create_data_record(mdc, changeset, "mdc")
    changeset
  end
end
