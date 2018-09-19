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

  def get_data() do
    %{stat_org: query(StatOrg, "limit"),
      stat_cda: query(StatCda, "limit"),
      cda: query(Cda, "limit"),
      cda_file: query(CdaFile, "limit"),
      cdh: query(Cdh, "limit"),
      ruleadrg: query(RuleAdrg, "limit"),
      cmp: query(ChineseMedicinePatent, "limit"),
      cm: query(ChineseMedicine, "limit"),
      ruledrg: query(RuleDrg, "limit"),
      ruleicd9: query(RuleIcd9, "limit"),
      ruleicd10: query(RuleIcd10, "limit"),
      rulemdc: query(RuleMdc, "limit"),
      libwt4: query(LibWt4, "limit"),
      wt4: query(Wt4, "limit"),
      rule_cda_icd10: query(RuleCdaIcd10, "limit"),
      rule_cda_icd9: query(RuleCdaIcd9, "limit"),
      rule_examine: query(RuleExamine, "limit"),
      rule_pharmacy: query(RulePharmacy, "limit"),
      rule_sign: query(RuleSign, "limit"),
      rule_symptom: query(RuleSymptom, "limit")}
  end

  def get(table) do
    case table do
      "stat_org"-> query(StatOrg, "all")
      "stat_cda"-> query(StatCda, "all")
      "cda"-> query(Cda, "all")
      "cda_file"-> query(CdaFile, "all")
      "cdh"-> query(Cdh, "all")
      "ruleadrg"-> query(RuleAdrg, "all")
      "cmp"-> query(ChineseMedicinePatent, "all")
      "cm"-> query(ChineseMedicine, "all")
      "ruledrg"-> query(RuleDrg, "all")
      "ruleicd9"-> query(RuleIcd9, "all")
      "ruleicd10"-> query(RuleIcd10, "all")
      "rulemdc"-> query(RuleMdc, "all")
      "libwt4"-> query(LibWt4, "all")
      "wt4"-> query(Wt4, "all")
      "rule_cda_icd10"-> query(RuleCdaIcd10, "all")
      "rule_cda_icd9"-> query(RuleCdaIcd9, "all")
      "rule_examine"-> query(RuleExamine, "all")
      "rule_pharmacy"-> query(RulePharmacy, "all")
      "rule_sign"-> query(RuleSign, "all")
      "rule_symptom"-> query(RuleSymptom, "all")
    end
  end

  def insert(table, data) do
    case table do
      "stat_org"-> %StatOrg{}|>StatOrg.changeset(data)
      "stat_cda"-> %StatCda{}|>StatCda.changeset(data)
      "cda"-> %Cda{}|>Cda.changeset(data)
      "cda_file"-> %CdaFile{}|>CdaFile.changeset(data)
      "cdh"-> %Cdh{}|>Cdh.changeset(data)
      "ruleadrg"-> %RuleAdrg{}|>RuleAdrg.changeset(data)
      "cmp"-> %ChineseMedicinePatent{}|>ChineseMedicinePatent.changeset(data)
      "cm"-> %ChineseMedicine{}|>ChineseMedicine.changeset(data)
      "ruledrg"-> %RuleDrg{}|>RuleDrg.changeset(data)
      "ruleicd9"-> %RuleIcd9{}|>RuleIcd9.changeset(data)
      "ruleicd10"-> %RuleIcd10{}|>RuleIcd10.changeset(data)
      "rulemdc"-> %RuleMdc{}|>RuleMdc.changeset(data)
      "libwt4"-> %LibWt4{}|>LibWt4.changeset(data)
      "wt4"-> %Wt4{}|>Wt4.changeset(data)
      "rule_cda_icd10"-> %RuleCdaIcd10{}|>RuleCdaIcd10.changeset(data)
      "rule_cda_icd9"-> %RuleCdaIcd9{}|>RuleCdaIcd9.changeset(data)
      "rule_examine"-> %RuleExamine{}|>RuleExamine.changeset(data)
      "rule_pharmacy"-> %RulePharmacy{}|>RulePharmacy.changeset(data)
      "rule_sign"-> %RuleSign{}|>RuleSign.changeset(data)
      "rule_symptom"-> %RuleSymptom{}|>RuleSymptom.changeset(data)
    end
    |>Repo.insert
  end

  defp query(table, type) do
    case type do
      "limit" ->
        from(p in table)
        |> select([p], p.inserted_at)
        |> order_by([p], [desc: p.inserted_at])
        |> limit([p], 1)
      _ ->
        from(p in table)
    end
    |> Repo.all
  end

end
