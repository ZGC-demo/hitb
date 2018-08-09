defmodule Hitb.Library.Repo.Migrations.RuleCdaIcd10 do
    use Ecto.Migration

  def change do
    create table(:rule_cda_icd10) do
      add :code, :string
      add :name, :string
      add :symptom, {:array, :string} #症状
      add :breathe, {:array, :string} #呼吸区间
      add :body_heat, {:array, :string} #心跳区间
      add :sphygums, {:array, :string} #脉搏区间
      add :blood_pressure, {:array, :string} #血压区间
      add :examine, {:array, :string} #检查
      timestamps()
    end
  end
end
