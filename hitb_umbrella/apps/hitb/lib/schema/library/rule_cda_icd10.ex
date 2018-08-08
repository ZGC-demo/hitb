defmodule Hitb.Library.RuleCdaIcd10 do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_cda_icd10" do
    field :code, :string
    field :name, :string
    field :symptom, {:array, :string} #症状
    field :breathe, {:array, :string} #呼吸区间
    field :body_heat, {:array, :string} #心跳区间
    field :sphygums, {:array, :string} #脉搏区间
    field :blood_pressure, {:array, :string} #血压区间
    field :examine, {:array, :string} #检查
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:code, :name, :symptom, :breathe, :body_heat, :sphygums, :blood_pressure, :examine])
    |> validate_required([:code, :symptom, :breathe, :body_heat, :sphygums, :blood_pressure, :examine])
  end

end
