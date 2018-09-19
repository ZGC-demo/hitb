defmodule Block.Library.RuleSymptom do
  use Ecto.Schema
  import Ecto.Changeset
  #主诉
  schema "rule_symptom" do
    field :symptom, :string
    field :icd9_a, {:array, :string}
    field :icd10_a, {:array, :string}
    field :pharmacys, {:array, :string}
    field :create_user, :string
    field :update_user, :string
    field :previous_hash, :string
    field :hash, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(rule_symptom, params \\ %{}) do
    changeset = rule_symptom
      |> cast(params, [:symptom, :icd9_a, :icd10_a, :pharmacys, :create_user, :update_user, :previous_hash, :hash])
      |> validate_required([:symptom, :pharmacys, :create_user, :update_user, :previous_hash, :hash])
      |> unique_constraint(:hash)
    Block.create_data_record(rule_symptom, changeset, "rule_symptom")
    changeset
  end

end
