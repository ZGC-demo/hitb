defmodule Library.RuleCdaStatService do
  import Ecto.Query
  alias Hitb.Repo
  alias Hitb.Library.RuleSymptom #主诉
  alias Hitb.Library.RuleSign #生命体征
  alias Hitb.Library.RuleCdaIcd10 #初步诊断
  alias Hitb.Library.RuleExamine #检查
  alias Hitb.Library.RulePharmacy #药品
  def symptom_serach(key, section) do
    result =
      case section do
        "主诉" ->
          Repo.get_by(RuleSymptom, symptom: key)
        "生命体征" ->
          Repo.get_by(RuleSign, sign: key)
        "初步诊断" ->
          Repo.get_by(RuleCdaIcd10, code: key)
        "处理意见" ->
          Repo.get_by(RulePharmacy, pharmacy: key)
        "辅助检查" ->
          Repo.get_by(RuleExamine, examine: key)
        _ -> %{}
      end
    case result do
      nil -> %{section: section}
      _ ->
      result = Map.drop(result, [:id, :__meta__, :__struct__])
      Map.put(result, :section, section)
    end
  end
end
