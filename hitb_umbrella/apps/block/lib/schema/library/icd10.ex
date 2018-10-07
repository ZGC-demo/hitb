defmodule Block.Library.Icd10 do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Library.Icd10

  schema "icd10" do
    field :code, :string
    field :codes, {:array, :string}
    field :name, :string
    field :icdcc, :string
    field :icdc, :string
    field :icdc_az, :string
    field :adrg, {:array, :string}
    field :drg, {:array, :string}
    field :cc, :boolean, default: false
    field :nocc_1, {:array, :string}
    field :nocc_a, {:array, :string}
    field :nocc_aa, {:array, :string}
    field :year, :string
    field :mcc, :boolean, default: false
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end

  def changeset(%Icd10{} = icd10, attrs) do
    changeset = icd10
      |> cast(attrs, [:code, :name, :icdcc, :icdc, :icdc_az, :adrg, :drg, :cc, :nocc_1, :nocc_a, :nocc_aa, :mcc, :codes, :previous_hash, :hash, :datetime])
      |> validate_required([:codes, :name, :adrg, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(icd10, changeset, "icd10")
    changeset
  end
end
