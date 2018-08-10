defmodule Hitb.Library.RuleExamine do
  #检查表
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_examine" do
    field :examine, :string
    field :icd10_a, {:array, :string}
    field :icd10_b, {:array, :string}
    field :create_user, :string
    field :update_user, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:pharmacy, :icd10_a, :icd10_b, :create_user, :update_user])
    |> validate_required([:pharmacy, :icd10_a, :icd10_b, :create_user, :update_user])
  end

end
