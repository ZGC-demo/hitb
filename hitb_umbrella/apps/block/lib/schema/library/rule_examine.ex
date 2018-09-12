defmodule Block.Library.RuleExamine do
  #检查表
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_examine" do
    field :examine, :string
    field :icd10_a, {:array, :string}
    field :icd10_b, {:array, :string}
    field :create_user, :string
    field :update_user, :string
    field :previous_hash, :string
    field :hash, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(rule_examine, params \\ %{}) do
    changeset = rule_examine
      |> cast(params, [:examine, :icd10_a, :icd10_b, :create_user, :update_user, :previous_hash, :hash])
      |> validate_required([:examine, :icd10_a, :icd10_b, :create_user, :update_user, :previous_hash, :hash])
    Block.create_data_record(changeset, "rule_examine")
    changeset
  end

end
