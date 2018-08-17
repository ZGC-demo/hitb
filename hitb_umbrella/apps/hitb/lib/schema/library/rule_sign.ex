defmodule Hitb.Library.RuleSign do
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
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:sign, :create_user, :update_user])
    |> validate_required([:sign, :create_user, :update_user])
  end

end
