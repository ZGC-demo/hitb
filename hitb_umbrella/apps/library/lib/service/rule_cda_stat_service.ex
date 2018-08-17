defmodule Library.RuleCdaStatService do
  alias Hitb.Repo
  import Ecto.Query
  alias Hitb.Library.RuleSymptom #主诉
  alias Hitb.Library.RuleSign #生命体征
  alias Hitb.Library.RuleCdaIcd10 #初步诊断
  alias Hitb.Library.RuleExamine #检查
  alias Hitb.Library.RulePharmacy #药品
  alias Block.Repo, as: BlockRepo
  alias Block.Library.RuleSymptom, as: BlockRuleSymptom #主诉
  alias Block.Library.RuleSign, as: BlockRuleSign #生命体征
  alias Block.Library.RuleCdaIcd10, as: BlockRuleCdaIcd10 #初步诊断
  alias Block.Library.RuleExamine, as: BlockRuleExamine #检查
  alias Block.Library.RulePharmacy, as: BlockRulePharmacy #药品
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

  def symptom_count(username) do
    #
    num1 = Repo.all(from p in RuleSymptom, where: p.create_user == ^username, select: count(p.id))|>List.first
    num2 = Repo.all(from p in RuleSign, where: p.create_user == ^username, select: count(p.id))|>List.first
    num3 = Repo.all(from p in RuleCdaIcd10, where: p.create_user == ^username, select: count(p.id))|>List.first
    num4 = Repo.all(from p in RulePharmacy, where: p.create_user == ^username, select: count(p.id))|>List.first
    num5 = Repo.all(from p in RuleExamine, where: p.create_user == ^username, select: count(p.id))|>List.first
    user = [num1, num2, num3, num4, num5]|>Enum.sum
    #
    num1 = Repo.all(from p in RuleSymptom, select: count(p.id))|>List.first
    num2 = Repo.all(from p in RuleSign, select: count(p.id))|>List.first
    num3 = Repo.all(from p in RuleCdaIcd10, select: count(p.id))|>List.first
    num4 = Repo.all(from p in RulePharmacy, select: count(p.id))|>List.first
    num5 = Repo.all(from p in RuleExamine, select: count(p.id))|>List.first
    server = [num1, num2, num3, num4, num5]|>Enum.sum
    #
    num1 = BlockRepo.all(from p in BlockRuleSymptom, where: p.create_user == ^username, select: count(p.id))|>List.first
    num2 = BlockRepo.all(from p in BlockRuleSign, where: p.create_user == ^username, select: count(p.id))|>List.first
    num3 = BlockRepo.all(from p in BlockRuleCdaIcd10, where: p.create_user == ^username, select: count(p.id))|>List.first
    num4 = BlockRepo.all(from p in BlockRuleExamine, where: p.create_user == ^username, select: count(p.id))|>List.first
    num5 = BlockRepo.all(from p in BlockRulePharmacy, where: p.create_user == ^username, select: count(p.id))|>List.first
    block = [num1, num2, num3, num4, num5]|>Enum.sum
    %{user: user, server: server, block: block}
  end
end
