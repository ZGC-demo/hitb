defmodule Block.Library.Drg do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Library.Drg

  schema "drg" do
    field :code, :string
    field :name, :string
    field :mdc, :string
    field :adrg, :string
    field :age, {:array, :string}
    # field :ltage, :integer
    field :sf0108, {:array, :string}
    field :mcc, :boolean, default: false
    field :cc, :boolean, default: false
    field :diags_code, {:array, :string}
    field :day, {:array, :string}
    field :year, :string
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end


  def changeset(%Drg{} = drg, attrs) do
    changeset = drg
      |> cast(attrs, [:code, :name, :mdc, :adrg, :age, :sf0108, :mcc, :cc, :diags_code, :day, :previous_hash, :hash, :datetime])
      |> validate_required([:code, :mdc, :adrg, :age, :sf0108, :mcc, :cc, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(drg, changeset, "drg")
    changeset
  end
end
