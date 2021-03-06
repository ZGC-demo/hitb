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
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(rule_cda_icd9, params \\ %{}) do
    changeset = rule_cda_icd9
      |> cast(params, [:code, :name, :symptoms, :breathe, :body_heat, :sphygums, :blood_pressure, :examines, :create_user, :update_user, :previous_hash, :hash, :datetime])
      |> validate_required([:code, :symptoms, :breathe, :body_heat, :sphygums, :blood_pressure, :examines, :create_user, :update_user, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(rule_cda_icd9, changeset, "rule_cda_icd9")
    changeset
  end

end
