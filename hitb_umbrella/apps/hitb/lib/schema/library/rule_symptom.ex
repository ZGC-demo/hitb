defmodule Hitb.Library.RuleSymptom do
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
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:symptom, :icd9_a, :icd10_a, :pharmacys, :create_user, :update_user])
    |> validate_required([:symptom, :pharmacys, :create_user, :update_user])
  end

end
