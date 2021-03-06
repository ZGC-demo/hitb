defmodule Block.Library.RuleAdrg do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_adrg" do
    field :code, :string
    field :name, :string
    field :drgs_1, {:array, :string}
    field :icd10_a, {:array, :string}
    field :icd10_aa, {:array, :string}
    field :icd10_acc, {:array, :string}
    field :icd10_b, {:array, :string}
    field :icd10_bb, {:array, :string}
    field :icd10_bcc, {:array, :string}
    field :icd9_a, {:array, :string}
    field :icd9_aa, {:array, :string}
    field :icd9_acc, {:array, :string}
    field :icd9_b, {:array, :string}
    field :icd9_bb, {:array, :string}
    field :icd9_bcc, {:array, :string}
    field :mdc, :string
    field :org, :string
    field :year, :string
    field :version, :string
    field :plat, :string
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(rule_adrg, params \\ %{}) do
    changeset = rule_adrg
      |> cast(params, [:code, :name, :drgs_1, :icd10_a, :icd10_aa, :icd10_acc, :icd10_b, :icd10_bb, :icd10_bcc, :icd9_a, :icd9_aa, :icd9_acc, :icd9_b, :icd9_bb, :icd9_bcc, :mdc, :org, :year, :version, :plat, :previous_hash, :hash, :datetime])
      |> validate_required([:code, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(rule_adrg, changeset, "rule_adrg")
    changeset
  end
end
