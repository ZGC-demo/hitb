defmodule Block.Library.DrgRate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Library.DrgRate

  schema "drg_rate" do
    field :drg, :string
    field :name, :string
    field :rate, :float
    field :type, :string
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(%DrgRate{} = drg_rate, attrs) do
    changeset = drg_rate
      |> cast(attrs, [:drg, :name, :rate, :type, :previous_hash, :hash, :datetime])
      |> validate_required([:drg, :name, :rate, :type, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(drg_rate, changeset, "drg_rate")
    changeset
  end

end
