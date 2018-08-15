defmodule Block.LibraryService do
  import Ecto.Query
  alias Block.Repo
  alias Block.Library.Cdh
  alias Block.Library.LibWt4
  alias Block.Library.RuleMdc
  alias Block.Library.RuleAdrg
  alias Block.Library.RuleDrg
  alias Block.Library.RuleIcd9
  alias Block.Library.RuleIcd10
  alias Block.Library.ChineseMedicine
  alias Block.Library.ChineseMedicinePatent
  alias Block.Library.RuleCdaIcd10
  alias Block.Library.RuleCdaIcd9
  alias Block.Library.RuleExamine
  alias Block.Library.RulePharmacy
  alias Block.Library.RuleSign
  alias Block.Library.RuleSymptom


  def get_last(table, file_name)do
    case table do
      "cdh" -> from(p in Cdh)
      "rule_mdc" -> from(p in RuleMdc)
      "rule_adrg" -> from(p in RuleAdrg)
      "rule_drg" -> from(p in RuleDrg)
      "rule_icd9" -> from(p in RuleIcd9)
      "rule_icd10" -> from(p in RuleIcd10)
      "chinese_medicine" -> from(p in ChineseMedicine)
      "chinese_medicine_patent" -> from(p in ChineseMedicinePatent)
      "lib_wt4" ->
        case file_name do
          "" -> from(p in LibWt4)
          _ -> from(p in LibWt4)|>where([p], p.type == ^file_name)
        end
      "rule_cda_icd10" -> from(p in RuleCdaIcd10)
      "rule_cda_icd9" -> from(p in RuleCdaIcd9)
      "rule_examine" -> from(p in RuleExamine)
      "rule_pharmacy" -> from(p in RulePharmacy)
      "rule_sign" -> from(p in RuleSign)
      "rule_symptom" -> from(p in RuleSymptom)
    end
    |>order_by([p], [desc: p.inserted_at])
    |>limit([p], 1)
    |>Repo.all
  end

  def get_all(table) do
    case table do
      "cdh" -> from(p in Cdh)
      "rule_mdc" -> from(p in RuleMdc)
      "rule_adrg" -> from(p in RuleAdrg)
      "rule_drg" -> from(p in RuleDrg)
      "rule_icd9" -> from(p in RuleIcd9)
      "rule_icd10" -> from(p in RuleIcd10)
      "chinese_medicine" -> from(p in ChineseMedicine)
      "chinese_medicine_patent" -> from(p in ChineseMedicinePatent)
      "lib_wt4" -> from(p in LibWt4)
      "rule_cda_icd10" -> from(p in RuleCdaIcd10)
      "rule_cda_icd9" -> from(p in RuleCdaIcd9)
      "rule_examine" -> from(p in RuleExamine)
      "rule_pharmacy" -> from(p in RulePharmacy)
      "rule_sign" -> from(p in RuleSign)
      "rule_symptom" -> from(p in RuleSymptom)
    end
    |>Repo.all
  end

  def get_num(table)do
    case table do
      "cdh" -> from(p in Cdh)
      "rule_mdc" -> from(p in RuleMdc)
      "rule_adrg" -> from(p in RuleAdrg)
      "rule_drg" -> from(p in RuleDrg)
      "rule_icd9" -> from(p in RuleIcd9)
      "rule_icd10" -> from(p in RuleIcd10)
      "chinese_medicine" -> from(p in ChineseMedicine)
      "chinese_medicine_patent" -> from(p in ChineseMedicinePatent)
      "lib_wt4" -> from(p in LibWt4)
      "rule_cda_icd10" -> from(p in RuleCdaIcd10)
      "rule_cda_icd9" -> from(p in RuleCdaIcd9)
      "rule_examine" -> from(p in RuleExamine)
      "rule_pharmacy" -> from(p in RulePharmacy)
      "rule_sign" -> from(p in RuleSign)
      "rule_symptom" -> from(p in RuleSymptom)
    end
    |>select([p], count(p.id))
    |>Repo.all
    |>List.first
  end

  def create(table, attr) do
    case table do
      "cdh" -> %Cdh{}|>Cdh.changeset(attr)
      "rule_mdc" -> %RuleMdc{}|>RuleMdc.changeset(attr)
      "rule_adrg" -> %RuleAdrg{}|>RuleAdrg.changeset(attr)
      "rule_drg" -> %RuleDrg{}|>RuleDrg.changeset(attr)
      "rule_icd9" -> %RuleIcd9{}|>RuleIcd9.changeset(attr)
      "rule_icd10" -> %RuleIcd10{}|>RuleIcd10.changeset(attr)
      "chinese_medicine" -> %ChineseMedicine{}|>ChineseMedicine.changeset(attr)
      "chinese_medicine_patent" -> %ChineseMedicinePatent{}|>ChineseMedicinePatent.changeset(attr)
      "lib_wt4" -> %LibWt4{}|>LibWt4.changeset(attr)
      "rule_cda_icd10" -> %RuleCdaIcd10{}|>RuleCdaIcd10.changeset(attr)
      "rule_cda_icd9" -> %RuleCdaIcd9{}|>RuleCdaIcd9.changeset(attr)
      "rule_examine" -> %RuleExamine{}|>RuleExamine.changeset(attr)
      "rule_pharmacy" -> %RulePharmacy{}|>RulePharmacy.changeset(attr)
      "rule_sign" -> %RuleSign{}|>RuleSign.changeset(attr)
      "rule_symptom" -> %RuleSymptom{}|>RuleSymptom.changeset(attr)
    end
    |>Repo.insert
  end

  def get_block_file() do
    [Repo.all(from p in RuleMdc, select: %{table: "mdc", count: count(p.id)}),
    Repo.all(from p in RuleAdrg, select: %{table: "adrg", count: count(p.id)}),
    Repo.all(from p in RuleDrg, select: %{table: "drg", count: count(p.id)}),
    Repo.all(from p in RuleIcd9, select: %{table: "icd9", count: count(p.id)}),
    Repo.all(from p in RuleIcd10, select: %{table: "icd10", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "基本信息", select: %{table: "基本信息", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "街道乡镇代码", select: %{table: "街道乡镇代码", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "民族", select: %{table: "民族", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "区县编码", select: %{table: "区县编码", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "手术血型", select: %{table: "手术血型", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "出入院编码", select: %{table: "出入院编码", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "肿瘤编码", select: %{table: "肿瘤编码", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "科别代码", select: %{table: "科别代码", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "病理诊断编码", select: %{table: "病理诊断编码", count: count(p.id)}),
    Repo.all(from p in LibWt4, where: p.type == "医保诊断依据", select: %{table: "医保诊断依据", count: count(p.id)}),
    Repo.all(from p in ChineseMedicine, select: %{table: "中药", count: count(p.id)}),
    Repo.all(from p in ChineseMedicinePatent, select: %{table: "中成药", count: count(p.id)})
    ]
    |>List.flatten
    |>Enum.reject(fn x -> x.count == 0 end)
    |>Enum.map(fn x -> "#{x.table}.csv" end)
  end
end
