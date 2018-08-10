defmodule Hitb.Library.RuleSign do
  #体征
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_sign" do
    field :sign, :string
    field :icd9_a, {:array, :string}
    field :icd10_a, {:array, :string}
    field :pharmacy, {:array, :string}
    # timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:symptom, :icd9_a, :icd10_a, :pharmacy])
    |> validate_required([:symptom, :pharmacy])
  end

end
