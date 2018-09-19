defmodule Block.Library.RuleSign do
  #体征
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_sign" do
    field :sign, :string
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

  def changeset(rule_sign, params \\ %{}) do
    changeset = rule_sign
      |> cast(params, [:sign, :icd9_a, :icd10_a, :pharmacys, :create_user, :update_user, :previous_hash, :hash])
      |> validate_required([:sign, :pharmacys, :create_user, :update_user, :previous_hash, :hash])
      |> unique_constraint(:hash)
    Block.create_data_record(rule_sign, changeset, "rule_sign")
    changeset
  end

end
