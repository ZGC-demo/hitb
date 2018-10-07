defmodule Block.Library.RulePharmacy do
  #药品表
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_pharmacy" do
    field :pharmacy, :string
    field :icd10_a, {:array, :string}
    field :symptoms, {:array, :string}
    field :create_user, :string
    field :update_user, :string
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(rule_pharmacy, params \\ %{}) do
    changeset = rule_pharmacy
      |> cast(params, [:pharmacy, :icd10_a, :symptoms, :create_user, :update_user, :previous_hash, :hash, :datetime])
      |> validate_required([:pharmacy, :icd10_a, :symptoms, :create_user, :update_user, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(rule_pharmacy, changeset, "rule_pharmacy")
    changeset
  end

end
