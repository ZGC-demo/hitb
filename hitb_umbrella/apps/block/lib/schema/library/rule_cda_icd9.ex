defmodule Block.Library.RuleCdaIcd9 do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_cda_icd9" do
    field :code, :string
    field :name, :string
    field :symptoms, {:array, :string} #症状
    field :breathe, {:array, :string} #呼吸区间
    field :body_heat, {:array, :string} #心跳区间
    field :sphygums, {:array, :string} #脉搏区间
    field :blood_pressure, {:array, :string} #血压区间
    field :examines, {:array, :string} #检查
    field :create_user, :string
    field :update_user, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:code, :name, :symptoms, :breathe, :body_heat, :sphygums, :blood_pressure, :examines, :create_user, :update_user])
    |> validate_required([:code, :symptoms, :breathe, :body_heat, :sphygums, :blood_pressure, :examines, :create_user, :update_user])
  end

end
