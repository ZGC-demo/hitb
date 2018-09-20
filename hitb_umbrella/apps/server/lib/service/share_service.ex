defmodule Server.ShareService do
  # import Ecto
  import Ecto.Query
  alias Hitb.Time
  alias Hitb.Repo
  alias Stat.Query

  alias Block.BlockService
  alias Block.AccountService
  alias Block.LibraryService
  alias Block.EditService
  alias Block.StatService

  alias Hitb.Edit.Cda
  alias Hitb.Library.Cdh
  alias Hitb.Stat.StatOrg
  alias Hitb.Stat.StatFile
  alias Hitb.Library.RuleMdc
  alias Hitb.Library.RuleAdrg
  alias Hitb.Library.RuleDrg
  alias Hitb.Library.RuleIcd9
  alias Hitb.Library.RuleIcd10
  alias Hitb.Library.LibWt4
  alias Hitb.Library.ChineseMedicinePatent
  alias Hitb.Library.ChineseMedicine
  alias Hitb.Server.User
  alias Library.RuleService
  alias Hitb.Library.RuleCdaIcd10
  alias Hitb.Library.RuleCdaIcd9
  alias Hitb.Library.RuleExamine
  alias Hitb.Library.RulePharmacy
  alias Hitb.Library.RuleSign
  alias Hitb.Library.RuleSymptom

  def share(type, file_name, username, content) do
    content =
      case content do
        "" -> content
        [] ->  ""
        _ -> Poison.decode!(content)
      end
    latest =
      case file_name do
        "cdh" -> LibraryService.get_last("cda","")
        "edit" -> EditService.get_cda()
        "stat" -> StatService.get_stat()
        "library" ->
          if(file_name in ["mdc", "adrg", "drg", "icd9", "icd10", "中药", "中成药", "诊断规则", "手术规则", "检查规则", "药品规则", "体征规则", "症状规则"])do
            LibraryService.get_last(file_name, "")
          else
            file_name2 = String.split(file_name, ".")|>List.first
            LibraryService.get_last(file_name2, "")
          end
      end
    previous_hash =
      case latest do
        [] -> ""
        _ -> List.first(latest)|>Map.get(:hash)
      end
    username = if(type == "edit")do String.split(file_name, "-")|>List.first else username end
    data =
      case type do
        "cdh" ->
          Repo.all(from p in Cdh)
        "edit" ->
          [_, editName] = String.split(file_name, "-")
          edit = Repo.all(from p in Cda, where: p.name == ^editName and p.username == ^username)
          bloackCdaFile = EditService.get_cda_file(username, editName)
          if !bloackCdaFile do
            body = %{"username" => username, "filename" => editName}
            EditService.create_cda_file(body)
          end
          edit
        "stat" ->
          page_type = Repo.get_by(StatFile, file_name: "#{file_name}")
          if(StatService.get_stat_file(file_name) == nil)do
            StatService.create_stat_file(Map.drop(page_type, [:id, :__meta__, :__struct__]))
          end
          [stat, _, _, _, _, _, _, _, _] = Query.getstat(username, 1, "org", "total", "", "", "", "org", "asc", page_type.page_type, 15, "download", "server")
          # content.
          cont = Enum.map(content, fn x ->
            x = String.split(x, ",")
            # %{org: Enum.at(x, 0), time: Enum.at(x, 1)}
            "#{Enum.at(x, 0)}-#{Enum.at(x, 1)}"
          end)
          Enum.reject(stat, fn x -> "#{x.org}-#{x.time}" not in cont end)
        "library" ->
          file_name2 = String.split(file_name, ".")|>List.first
          RuleService.client(1, "year", file_name2, "", "", "", 0, "server", "asc", "code", username).library
      end
    data =
      Enum.reduce(data, [[], previous_hash], fn x, acc ->
        [data, previous_hash] = acc
        hash =
          case type do
            "cdh" -> hash("#{x.content}#{x.name}#{x.type}")
            "edit" -> hash("#{x.name}#{x.content}")
            "stat" -> hash("#{x.org}#{x.time}#{x.org_type}#{x.time_type}")
            "library" ->
              cond do
                file_name in ["mdc", "adrg", "drg", "icd9", "icd10"] ->
                  hash("#{x.code}#{x.name}#{x.version}#{x.year}")
                true ->
                  hash("#{x.code}")
              end
          end
        x = Map.drop(x, [:id, :__meta__, :__struct__])
          |>Map.merge(%{hash: hash, previous_hash: previous_hash})
        [Enum.concat(data, [x]), hash]
      end)
      |>List.first
    user = Repo.get_by(User, username: username)
    if(user)do
      Enum.each(data, fn x ->
        LibraryService.create(type, x)
      end)
      secret = AccountService.getAccountByAddress(user.block_address).username
      block = BlockService.create_next_block("#{type}-#{file_name}", secret)
      BlockService.add_block(block)
    end
    :ok
  end

  def get_share() do
    #分析和病案部分
    stat_org = StatService.get_stat_num()
    last_stat_org = StatService.get_stat()
    edit = EditService.get_cda_num()
    last_edit = EditService.get_cda()
    re = [%{key: "edit", val: edit, last: last_edit}, %{key: "stat_org", val: stat_org, last: last_stat_org}]
    #规则部分
    list = ["cdh", "mdc", "adrg", "drg", "icd9", "icd10", "chinese_medicine", "chinese_medicine_patent", "lib_wt4", "rule_cda_icd10", "rule_cda_icd9", "rule_examine", "rule_pharmacy", "rule_sign", "rule_symptom"]
    result =
      Enum.map(list, fn x ->
        %{key: x, val: LibraryService.get_num(x)}
      end)
      |>Enum.map(fn x ->
          last =
            case x.val do
              0 -> "-"
              _ -> LibraryService.get_last(x.key, "")|>Map.get(:inserted_at)|>List.first|>Time.stime_ecto
            end
          Map.put(x, :last, last)
        end)
    result ++ re
  end

  def insert(table, _time) do
    hashs =
      cond do
        table == "edit" ->
          Repo.all(from p in Cda, select: %{name: p.name, content: p.content})
          |>Enum.map(fn x -> hash("#{x.name}#{x.content}") end)
        table == "stat_org" ->
          Repo.all(from p in StatOrg, select: %{org: p.org, time: p.time, org_type: p.org_type, time_type: p.time_type})
          |>Enum.map(fn x -> hash("#{x.org}#{x.time}#{x.org_type}#{x.time_type}") end)
        table in ["mdc", "adrg", "drg", "icd9", "icd10"] ->
          case table do
            "mdc" ->
              Repo.all(from p in RuleMdc, select: %{code: p.code, name: p.name, version: p.version, year: p.year, org: p.org, plat: p.plat})
            "adrg" ->
              Repo.all(from p in RuleAdrg, select: %{code: p.code, name: p.name, version: p.version, year: p.year, org: p.org, plat: p.plat})
            "drg" ->
              Repo.all(from p in RuleDrg, select: %{code: p.code, name: p.name, version: p.version, year: p.year, org: p.org, plat: p.plat})
            "icd9" ->
              Repo.all(from p in RuleIcd9, select: %{code: p.code, name: p.name, version: p.version, year: p.year, org: p.org, plat: p.plat})
            "icd10" ->
              Repo.all(from p in RuleIcd10, select: %{code: p.code, name: p.name, version: p.version, year: p.year, org: p.org, plat: p.plat})
          end
          |>Enum.map(fn x -> hash("#{x.code}#{x.name}#{x.version}#{x.year}#{x.org}#{x.plat}") end)
        table == "chinese_medicine" ->
          Repo.all(from p in ChineseMedicine, select: %{code: p.code, name: p.name})
          |>Enum.map(fn x -> hash("#{x.code}#{x.name}") end)
        table == "chinese_medicine_patent" ->
          Repo.all(from p in ChineseMedicinePatent, select: %{code: p.code, name: p.name})
          |>Enum.map(fn x -> hash("#{x.code}#{x.name}") end)
        table == "rule_cda_icd10" ->
          Repo.all(from p in RuleCdaIcd10, select: %{code: p.code})
          |>Enum.map(fn x -> hash("#{x.code}") end)
        table == "rule_cda_icd9" ->
          Repo.all(from p in RuleCdaIcd9, select: %{code: p.code})
          |>Enum.map(fn x -> hash("#{x.code}") end)
        table == "rule_examine" ->
          Repo.all(from p in RuleExamine, select: %{code: p.code})
          |>Enum.map(fn x -> hash("#{x.code}") end)
        table == "rule_pharmacy" ->
          Repo.all(from p in RulePharmacy, select: %{code: p.code})
          |>Enum.map(fn x -> hash("#{x.code}") end)
        table == "rule_sign" ->
          Repo.all(from p in RuleSign, select: %{code: p.code})
          |>Enum.map(fn x -> hash("#{x.code}") end)
        table == "rule_symptom" ->
          Repo.all(from p in RuleSymptom, select: %{code: p.code})
          |>Enum.map(fn x -> hash("#{x.code}") end)
        true ->
          Repo.all(from p in LibWt4, select: %{code: p.code, name: p.name})
          |>Enum.map(fn x -> hash("#{x.code}#{x.name}") end)
      end
    data =
      case table do
        "edit" ->  EditService.get_cdas()
        "stat_org" -> StatService.get_stats()
        _ -> LibraryService.get_all(table)
      end
    Enum.reject(data, fn x -> x.hash in hashs end)
    |>Enum.map(fn x ->
        x = Map.drop(x, [:id, :__meta__, :__struct__])
        case table do
          "edit" -> %Cda{}|>Cda.changeset(x)
          "stat_org" -> %StatOrg{}|>StatOrg.changeset(x)
          "mdc" -> %RuleMdc{}|>RuleMdc.changeset(x)
          "adrg" -> %RuleAdrg{}|>RuleAdrg.changeset(x)
          "drg" -> %RuleDrg{}|>RuleDrg.changeset(x)
          "icd9" -> %RuleIcd9{}|>RuleIcd9.changeset(x)
          "icd10" -> %RuleIcd10{}|>RuleIcd10.changeset(x)
          "chinese_medicine" -> %ChineseMedicine{}|>ChineseMedicine.changeset(x)
          "chinese_medicine_patent" -> %ChineseMedicinePatent{}|>ChineseMedicinePatent.changeset(x)
          "lib_wt4" -> %LibWt4{}|>LibWt4.changeset(x)
          "rule_cda_icd10" -> %RuleCdaIcd10{}|>RuleCdaIcd10.changeset(x)
          "rule_cda_icd9" -> %RuleCdaIcd9{}|>RuleCdaIcd9.changeset(x)
          "rule_examine" -> %RuleExamine{}|>RuleExamine.changeset(x)
          "rule_pharmacy" -> %RulePharmacy{}|>RulePharmacy.changeset(x)
          "rule_sign" -> %RuleSign{}|>RuleSign.changeset(x)
          "rule_symptom" -> %RuleSymptom{}|>RuleSymptom.changeset(x)
        end
        |>Repo.insert
      end)
  end

  defp hash(s) do
    s = :crypto.hash(:sha256, s)
    |> Base.encode64

    [~r/\+/, ~r/ /, ~r/\=/, ~r/\%/, ~r/\//, ~r/\#/, ~r/\$/, ~r/\~/, ~r/\'/, ~r/\@/, ~r/\*/, ~r/\-/]
    |> Enum.reduce(s, fn x, acc -> Regex.replace(x, acc, "") end)
  end

end
