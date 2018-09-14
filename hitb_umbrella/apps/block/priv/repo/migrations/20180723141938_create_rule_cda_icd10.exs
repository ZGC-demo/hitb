defmodule Block.Library.Repo.Migrations.RuleCdaIcd10 do
    use Ecto.Migration

  def change do
    create table(:rule_cda_icd10) do
      add :code, :string
      add :name, :string
      add :symptoms, {:array, :string} #症状
      add :breathe, {:array, :string} #呼吸区间
      add :body_heat, {:array, :string} #心跳区间
      add :sphygums, {:array, :string} #脉搏区间
      add :blood_pressure, {:array, :string} #血压区间
      add :examines, {:array, :string} #检查
      add :create_user, :string
      add :update_user, :string
      add :previous_hash, :string
      add :hash, :string
      timestamps()
    end
  end
end
