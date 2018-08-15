defmodule Block.SyncService do
  import Ecto.Query, warn: false
  alias Block.Repo
  alias Block.Edit.Cda
  alias Block.Edit.CdaFile
  alias Block.Library.RuleCdaIcd10
  alias Block.Library.RuleCdaIcd9
  alias Block.Library.RuleExamine
  alias Block.Library.RulePharmacy
  alias Block.Library.RuleSign
  alias Block.Library.RuleSymptom
  alias Block.Library.Cdh
  alias Block.Library.RuleAdrg
  alias Block.Library.ChineseMedicinePatent
  alias Block.Library.ChineseMedicine
  alias Block.Library.RuleDrg
  alias Block.Library.RuleIcd9
  alias Block.Library.RuleIcd10
  alias Block.Library.RuleMdc
  alias Block.Library.LibWt4
  alias Block.Library.Wt4
  alias Block.Stat.StatOrg
  alias Block.Stat.StatCda

  def get_cda_hash do
    Repo.all(from p in Cda, select: p.hash)
  end

  def get_cda_file_hash do
    Repo.all(from p in CdaFile, select: p.hash)
  end

  def get_cah_hash do
    Repo.all(from p in Cdh, select: p.hash)
  end

  def get_statorg_hash do
    Repo.all(from p in StatOrg, select: p.hash)
  end


  def get_ruleadrg_hash do
    Repo.all(from p in RuleAdrg, select: p.hash)
  end

  def get_cmp_hash do
    Repo.all(from p in ChineseMedicinePatent, select: p.hash)
  end

  def get_cm_hash do
    Repo.all(from p in ChineseMedicine, select: p.hash)
  end

  def get_ruledrg_hash do
    Repo.all(from p in RuleDrg, select: p.hash)
  end

  def get_ruleicd9_hash do
    Repo.all(from p in RuleIcd9, select: p.hash)
  end

  def get_ruleicd10_hash do
    Repo.all(from p in RuleIcd10, select: p.hash)
  end

  def get_rulemdc_hash do
    Repo.all(from p in RuleMdc, select: p.hash)
  end

  def get_libwt4_hash do
    Repo.all(from p in LibWt4, select: p.hash)
  end

  def get_wt4_hash do
    Repo.all(from p in Wt4, select: p.hash)
  end

  def get_stat_cda_hash do
    Repo.all(from p in StatCda, select: p.hash)
  end

  def get_rule_cda_icd10_hash do
    Repo.all(from p in RuleCdaIcd10, select: p.hash)
  end

  def get_rule_cda_icd9_hash do
    Repo.all(from p in RuleCdaIcd9, select: p.hash)
  end

  def get_rule_examine_hash do
    Repo.all(from p in RuleExamine, select: p.hash)
  end

  def get_rule_pharmacy_hash do
    Repo.all(from p in RulePharmacy, select: p.hash)
  end

  def get_rule_sign_hash do
    Repo.all(from p in RuleSign, select: p.hash)
  end

  def get_rule_symptom_hash do
    Repo.all(from p in RuleSymptom, select: p.hash)
  end

  def get_data(x, hash) do
    hash = if(hash == nil)do [] else hash end
    case x do
      "statorg_hash" -> Repo.all(StatOrg)
      "statcda_hash" -> Repo.all(StatCda)
      "cda_hash" -> Repo.all(Cda)
      "cda_file_hash" -> Repo.all(CdaFile)
      "cdh_hash" -> Repo.all(Cdh)
      "ruleadrg_hash" -> Repo.all(RuleAdrg)
      "cmp_hash" -> Repo.all(ChineseMedicinePatent)
      "cm_hash" -> Repo.all(ChineseMedicine)
      "ruledrg_hash" -> Repo.all(RuleDrg)
      "ruleicd9_hash" -> Repo.all(RuleIcd9)
      "ruleicd10_hash" -> Repo.all(RuleIcd10)
      "rulemdc_hash" -> Repo.all(RuleMdc)
      "libwt4_hash" -> Repo.all(LibWt4)
      "wt4_hash" -> Repo.all(Wt4)
      "rule_cda_icd10" -> Repo.all(RuleCdaIcd10)
      "rule_cda_icd9" -> Repo.all(RuleCdaIcd9)
      "rule_examine" -> Repo.all(RuleExamine)
      "rule_pharmacy" -> Repo.all(RulePharmacy)
      "rule_sign" -> Repo.all(RuleSign)
      "rule_symptom" -> Repo.all(RuleSymptom)
      _ -> []
    end
    |>Enum.reject(fn x -> x.hash in hash end)
    |>Enum.map(fn x -> Map.drop(x, [:__meta__, :__struct__, :id]) end)
  end

end
