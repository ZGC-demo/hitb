defmodule Block.Library.RuleCdaIcd10 do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_cda_icd10" do
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
    field :previous_hash, :string
    field :hash, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(rule_cda_icd10, params \\ %{}) do
    changeset = rule_cda_icd10
      |> cast(params, [:code, :name, :symptoms, :breathe, :body_heat, :sphygums, :blood_pressure, :examines, :create_user, :update_user, :previous_hash, :hash])
      |> validate_required([:code, :symptoms, :breathe, :body_heat, :sphygums, :blood_pressure, :examines, :create_user, :update_user, :previous_hash, :hash])
    Block.create_data_record(rule_cda_icd10, changeset, "rule_cda_icd10")
    changeset
  end

end
