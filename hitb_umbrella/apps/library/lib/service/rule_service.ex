defmodule Library.RuleService do
  # import Ecto
  import Ecto.Query
  alias Hitb.Page
  alias Hitb.Time
  alias Hitb.Repo, as: HitbRepo
  alias Block.Repo, as: BlockRepo
  alias Hitb.Library.RuleSymptom, as: HitbRuleSymptom
  alias Library.RuleQuery
  alias Hitb.Library.LibraryFile, as: HitbLibraryFile
  alias Library.Key
  alias Block.LibraryService
  alias Hitb.Library.RuleMdc, as: HitbRuleMdc
  alias Hitb.Library.RuleAdrg, as: HitbRuleAdrg
  alias Hitb.Library.RuleDrg, as: HitbRuleDrg
  alias Hitb.Library.RuleIcd9, as: HitbRuleIcd9
  alias Hitb.Library.RuleIcd10, as: HitbRuleIcd10
  alias Hitb.Library.LibWt4, as: HitbLibWt4
  alias Hitb.Library.ChineseMedicine, as: HitbChineseMedicine
  alias Hitb.Library.ChineseMedicinePatent, as: HitbChineseMedicinePatent
  alias Hitb.Library.WesternMedicine, as: HitbWesternMedicine
  alias Hitb.Library.RuleCdaIcd10
  alias Hitb.Library.RuleCdaIcd9
  alias Hitb.Library.RuleExamine
  alias Hitb.Library.RulePharmacy
  alias Hitb.Library.RuleSign
  alias Hitb.Library.RuleSymptom

  def json(page, type, tab_type, version, year, dissect, rows, _, _) do
    #取得分析结果
    [result, page_list, page_num, _, tab_type, _type, dissect, list, version, _] = RuleQuery.get_rule(page, type, tab_type, version, year, dissect, rows, "server", "asc", "code", "", "")
    #去除关键字段
    result = Enum.map(result, fn x -> Map.drop(x, [:__meta__, :__struct__]) end)
    %{result: result, page_list: page_list, page_num: page_num, tab_type: tab_type, type: type, dissect: dissect, list: list, version: version, year: year}
  end

  def file(server_type) do
    case server_type do
      "block" -> LibraryService.get_block_file()
      _ ->
        HitbRepo.all(from p in HitbLibraryFile, select: p.file_name)
        |>Enum.map(fn x -> "#{x}.csv" end)
    end
  end

  def client(page, type, tab_type, version, year, dissect, rows, server_type, order_type, order, username) do
    [result, page_list, page_num, count, _, _, _, list, _, _] = RuleQuery.get_rule(page, type, tab_type, version, year, dissect, rows, server_type, order_type, Key.en(order), "", username)
    result = RuleQuery.del_key(result, tab_type, username)
    result =
      case length(result) do
        0 ->
          schema = RuleQuery.tab(server_type, tab_type)
          keys =
            cond do
              tab_type in ["诊断规则", "手术规则", "检查规则", "药品", "药品规则", "体征规则", "症状规则"] ->
                Enum.reject(schema.__schema__(:fields), fn x -> x in [:__meta__, :__struct__, :inserted_at, :updated_at, :create_user, :update_user] end)
              true ->
                Enum.reject(schema.__schema__(:fields), fn x -> x in [:__meta__, :__struct__, :inserted_at, :updated_at, :icdc, :icdc_az, :icdcc, :nocc_1, :nocc_a, :nocc_aa, :org, :plat, :mdc, :icd9_a, :icd9_aa, :icd10_a, :icd10_aa, :drgs_1, :icd10_acc, :icd10_b, :icd10_bb, :icd10_bcc, :icd9_acc, :icd9_b, :icd9_bb, :icd9_bcc, :create_user, :update_user] end)
            end
          [Enum.map(keys, fn x -> Key.cn(x) end)]
        _ ->
          keys = Map.keys(List.first(result))|>Enum.map(fn x -> Key.cn(x) end)
          [keys] ++ Enum.map(result, fn x -> Map.values(x) end)
      end
    file_info = HitbRepo.get_by(HitbLibraryFile, file_name: tab_type)
    result =
      case file_info do
        nil -> []
        _ ->
        [["创建时间:#{Time.stime_ecto(file_info.inserted_at)}", "保存时间:#{Time.stime_ecto(file_info.updated_at)};创建用户:#{file_info.insert_user}", "修改用户:#{file_info.update_user}"] | result]
      end
    %{library: result, list: list, count: count, page_list: page_list, page: page_num, order: order, order_type: order_type}
  end

  #对比
  def contrast(table, id) do
    tab = RuleQuery.tab("server", table)
    result = String.split(id, "-")
      |>Enum.map(fn x ->
          x = String.to_integer(x)
          HitbRepo.all(from p in tab, where: p.id == ^x)
        end)
      |>List.flatten
    [result, c] =
      if(result != [])do
        a1 = List.first(result)
        a2 = List.last(result)
        a =[:name, :code, :version, :property, :option, :dissect, :cc, :mcc]
        b = Enum.map(a, fn x ->
          val1 = Map.get(a1, x)
          val2 = Map.get(a2, x)
          cond do
            val1 == nil -> nil
            val1 == val2 -> [Key.cn(x), "一致"]
            val1 !=val2 -> [Key.cn(x), "不一致"]
          end
        end)
        c = Enum.reject(b, fn x -> x == nil end)
        result = Enum.map(result, fn x ->
          Map.drop(x, [:__meta__, :__struct__])
        end)
        [result, c]
      else
        [[], []]
      end
    %{result: result, table: table, contrast: c}
  end

  #维度
  def details(code, table, version) do
    tab = RuleQuery.tab("server", table)
    result = HitbRepo.all(from p in tab, where: p.code == ^code)
    result1 = HitbRepo.all(from p in tab, where: p.code == ^code and p.version == ^version)
    result = Enum.map(result, fn x ->
      Map.drop(x, [:__meta__, :__struct__])
    end)
    result1 = Enum.map(result1, fn x ->
      Map.drop(x, [:__meta__, :__struct__])
    end)
     %{result: result, result1: List.first(result1), table: table}
  end

  # 模糊搜索
  def search(page, table, code) do
    skip = Page.skip(page, 10)
    tab = RuleQuery.tab("server", table)
    code = "%" <> code <> "%"
    result = from(w in tab, where: like(w.code, ^code) or like(w.name, ^code))
      |> limit([w], 10)
      |> offset([w], ^skip)
      |> order_by([w], [asc: w.id])
      |> HitbRepo.all
    query = from w in tab, where: like(w.code, ^code) or like(w.name, ^code), select: count(w.id)
    count = hd(HitbRepo.all(query))
    [page_num, page_list, _count] = Page.page_list(page, count, 10)
    result = Enum.map(result, fn x ->
      Map.drop(x, [:__meta__, :__struct__])
    end)
    %{table: result, page_num: page_num, page_list: page_list}
  end

  #下载
  def download(filename) do
    [result, _, _, _, _, _, _, _, _, _] = RuleQuery.get_rule(1, "", filename, "", "", "", 0, "server", "", "", "download", "")
    result = RuleQuery.del_key(result, filename, "")
    result =
      case length(result) do
        0 -> []
        _ ->
          keys = Map.keys(List.first(result))|>Enum.map(fn x -> Key.cn(x) end)
          [keys] ++ Enum.map(result, fn x -> Map.values(x) end)
      end
    %{result: result}
  end

  #搜索
  def rule_search(filename, value, servertype) do
    tab = RuleQuery.tab(servertype, filename)
    #取得要搜索表的表头
    keys =
      case servertype do
        "server" -> HitbRepo.all(from p in tab, limit: 1)
        "block" -> BlockRepo.all(from p in tab, limit: 1)
      end
      |>RuleQuery.del_key(filename, "")|>List.first|>Map.keys
    query = RuleQuery.table(filename, tab)
    query =
      case tab do
        Hitb.Library.LibWt4 ->
          value = "%#{value}%"
          query
          |>where([p], like(p.code, ^value) or like(p.name, ^value) or like(p.year, ^value))
        _ ->
        Enum.reduce(keys, query, fn x, acc ->
          value = "%#{value}%"
          acc
          |>or_where([p],  like(field(p, ^x), ^value))
        end)
      end
    result =
      case servertype do
        "server" -> HitbRepo.all(query)
        "block" -> BlockRepo.all(query)
      end
    result = RuleQuery.del_key(result, filename, "")
    result =
      case length(result) do
        0 -> []
        _ ->
          keys = Map.keys(List.first(result))|>Enum.map(fn x -> Key.cn(x) end)
          [keys] ++ Enum.map(result, fn x -> Map.values(x) end)
      end
    %{result: result}
  end

  def rule_symptom(symptom, icd9_a, icd10_a, pharmacy) do
    symptoms = HitbRepo.get_by(HitbRuleSymptom, symptom: symptom)
    if symptoms != nil do
      symptoms
      |> HitbRuleSymptom.changeset(%{icd9_a: icd9_a, icd10_a: icd10_a, pharmacy: pharmacy})
      |> HitbRepo.update()
      %{success: true, info: "保存成功"}
    else
      body = %{"symptom" => symptom, "icd9_a" => icd9_a, "icd10_a" => icd10_a, "pharmacy" => pharmacy}
      %HitbRuleSymptom{}
      |> HitbRuleSymptom.changeset(body)
      |> HitbRepo.insert()
      %{success: true, info: "保存成功"}
    end
  end

  def client_save(filename, server_type, username, data, rows, order_type, order) do
    schema = RuleQuery.tab(server_type, filename)
    if(length(data) > 0)do
      [result, _, _, _, _, _, _, _, _, _] = RuleQuery.get_rule(1, "", filename, "", "", "", rows, server_type, order_type, Key.en(order), "", username)
      # IO.inspect result
      #去掉文件头
      data = List.delete_at(data, 0)
      #取得表头
      header = data|>List.first|>String.split(",")|>Enum.map(fn x -> Key.en(x)|>String.to_atom end)
      #去掉表头,并拆分行列
      data = List.delete_at(data, 0)|>Enum.reject(fn x -> x == "" end)
      #将数组转换为对象
      data =
        Enum.map(data, fn x ->
          x = String.split(x, ",")
          Enum.reduce(header, %{}, fn k, acc ->
            field_type = schema.__schema__(:type, k)
            index = Enum.find_index(header, fn ks -> ks == k end)
            value = Enum.at(x, index)
            value =
              cond do
                k == :id and value in ["", "-"] -> ""
                k == :id -> String.to_integer(value)
                field_type == {:array, :string} -> String.split(value, "，")|>Enum.reject(fn x -> x == "" end)
                true -> value
              end
            Map.put(acc, k, value)
          end)
        end)
      data_id = Enum.map(data, fn x -> x.id end)
      #判断是否有要删除的
      Enum.reject(result, fn x -> x.id in data_id end)
      |>Enum.each(fn x ->
          HitbRepo.delete!(x)
        end)
      #判断是否有要添加的
      Enum.reject(data, fn x -> x.id != "" end)
      |>Enum.each(fn x ->
          x = Map.delete(x, :id)|>Map.merge(%{create_user: username, update_user: username})
          case filename do
            "mdc" -> %HitbRuleMdc{}|>HitbRuleMdc.changeset(x)
            "adrg" -> %HitbRuleAdrg{}|>HitbRuleAdrg.changeset(x)
            "drg" -> %HitbRuleDrg{}|>HitbRuleDrg.changeset(x)
            "icd9" -> %HitbRuleIcd9{}|>HitbRuleIcd9.changeset(x)
            "icd10" -> %HitbRuleIcd10{}|>HitbRuleIcd10.changeset(x)
            "中药" -> %HitbChineseMedicine{}|>HitbChineseMedicine.changeset(x)
            "中成药" -> %HitbChineseMedicinePatent{}|>HitbChineseMedicinePatent.changeset(x)
            "西药" -> %HitbWesternMedicine{}|>HitbWesternMedicine.changeset(x)
            "诊断规则" -> %RuleCdaIcd10{}|>RuleCdaIcd10.changeset(x)
            "手术规则" -> %RuleCdaIcd9{}|>RuleCdaIcd9.changeset(x)
            "检查规则" -> %RuleExamine{}|>RuleExamine.changeset(x)
            "药品规则" -> %RulePharmacy{}|>RulePharmacy.changeset(x)
            "体征规则" -> %RuleSign{}|>RuleSign.changeset(x)
            "症状规则" -> %RuleSymptom{}|>RuleSymptom.changeset(x)
            _ ->
              %HitbLibWt4{}
              |>HitbLibWt4.changeset(Map.merge(x, %{type: filename}))
          end
          |>HitbRepo.insert
        end)
      #用来判断是否修改
      result_key =
        Enum.map(result, fn x ->
          Enum.map(header, fn k ->
            Map.get(x, k)
          end)
          |>Enum.join(",")
        end)
      #判断修改
      Enum.reject(data, fn x -> x.id == "" end)
      |>Enum.reject(fn x -> join(header, x) in result_key end)
      |>Enum.each(fn x ->
          att = HitbRepo.get_by(schema, id: x.id)
          att
          |>schema.changeset(x)
          |>HitbRepo.update
        end)
    end
  end

  def client_save2(filename, server_type, username, data, rows, order_type, order) do
    schema = RuleQuery.tab(server_type, filename)
    if(length(data) > 0)do
      #去掉文件头
      data = List.delete_at(data, 0)
      #取得表头
      header = data|>List.first|>String.split(",")|>Enum.map(fn x -> Key.en(x)|>String.to_atom end)
      #去掉表头,并拆分行列
      data = List.delete_at(data, 0)|>Enum.reject(fn x -> x == "" end)
      #将数组转换为对象
      data =
        Enum.map(data, fn x ->
          x = String.split(x, ",")
          Enum.reduce(header, %{}, fn k, acc ->
            field_type = schema.__schema__(:type, k)
            index = Enum.find_index(header, fn ks -> ks == k end)
            value = Enum.at(x, index)
            value =
              cond do
                k == :id and value in ["", "-"] -> ""
                k == :id -> String.to_integer(value)
                field_type == {:array, :string} -> String.split(value, "，")|>Enum.reject(fn x -> x == "" end)
                true -> value
              end
            Map.put(acc, k, value)
          end)
        end)
      #判断是否存在id
      Enum.each(data, fn x ->
        case x.id do
          "" ->
            x = Map.delete(x, :id)|>Map.merge(%{create_user: username, update_user: username})
            case filename do
              "mdc" -> %HitbRuleMdc{}|>HitbRuleMdc.changeset(x)
              "adrg" -> %HitbRuleAdrg{}|>HitbRuleAdrg.changeset(x)
              "drg" -> %HitbRuleDrg{}|>HitbRuleDrg.changeset(x)
              "icd9" -> %HitbRuleIcd9{}|>HitbRuleIcd9.changeset(x)
              "icd10" -> %HitbRuleIcd10{}|>HitbRuleIcd10.changeset(x)
              "中药" -> %HitbChineseMedicine{}|>HitbChineseMedicine.changeset(x)
              "中成药" -> %HitbChineseMedicinePatent{}|>HitbChineseMedicinePatent.changeset(x)
              "西药" -> %HitbWesternMedicine{}|>HitbWesternMedicine.changeset(x)
              "诊断规则" -> %RuleCdaIcd10{}|>RuleCdaIcd10.changeset(x)
              "手术规则" -> %RuleCdaIcd9{}|>RuleCdaIcd9.changeset(x)
              "检查规则" -> %RuleExamine{}|>RuleExamine.changeset(x)
              "药品规则" -> %RulePharmacy{}|>RulePharmacy.changeset(x)
              "体征规则" -> %RuleSign{}|>RuleSign.changeset(x)
              "症状规则" -> %RuleSymptom{}|>RuleSymptom.changeset(x)
              _ ->
                %HitbLibWt4{}
                |>HitbLibWt4.changeset(Map.merge(x, %{type: filename}))
            end
            |>HitbRepo.insert
          _ ->
            HitbRepo.get_by(schema, id: x.id)
            |>schema.changeset(x)
            |>HitbRepo.update
        end
      end)
    end
  end

  defp join(header, data) do
    Enum.map(header, fn k -> Map.get(data, k) end)|>Enum.join(",")
  end


end
