defmodule Library.RuleService do
  # import Ecto
  import Ecto.Query
  alias Hitb.Page
  alias Hitb.Time
  alias Hitb.Repo
  alias Hitb.Library.RuleSymptom
  alias Library.RuleQuery
  alias Hitb.Library.LibraryFile
  alias Library.Key
  alias Hitb.Library.RuleMdc
  alias Hitb.Library.RuleAdrg
  alias Hitb.Library.RuleDrg
  alias Hitb.Library.RuleIcd9
  alias Hitb.Library.RuleIcd10
  alias Hitb.Library.LibWt4
  alias Hitb.Library.ChineseMedicine
  alias Hitb.Library.ChineseMedicinePatent
  alias Hitb.Library.WesternMedicine
  alias Hitb.Library.RuleCdaIcd10
  alias Hitb.Library.RuleCdaIcd9
  alias Hitb.Library.RuleExamine
  alias Hitb.Library.RulePharmacy
  alias Hitb.Library.RuleSign
  alias Hitb.Library.RuleSymptom

  alias Block.Repo, as: BlockRepo
  alias Block.LibraryService

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
        Repo.all(from p in LibraryFile, select: p.file_name)
        |>Enum.map(fn x -> "#{x}" end)
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
                Enum.reject(schema.__schema__(:fields), fn x -> x in [:__meta__, :__struct__, :inserted_at, :updated_at] end)
              true ->
                Enum.reject(schema.__schema__(:fields), fn x -> x in [:__meta__, :__struct__, :inserted_at, :updated_at, :icdc, :icdc_az, :icdcc, :nocc_1, :nocc_a, :nocc_aa, :org, :plat, :mdc, :icd9_a, :icd9_aa, :icd10_a, :icd10_aa, :drgs_1, :icd10_acc, :icd10_b, :icd10_bb, :icd10_bcc, :icd9_acc, :icd9_b, :icd9_bb, :icd9_bcc] end)
            end
          [Enum.map(keys, fn x -> Key.cn(x) end)]
        _ ->
          keys = Map.keys(List.first(result))|>Enum.map(fn x -> Key.cn(x) end)
          [keys] ++ Enum.map(result, fn x -> Map.values(x) end)
      end
    file_info = Repo.get_by(LibraryFile, file_name: tab_type)
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
          Repo.all(from p in tab, where: p.id == ^x)
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
    result = Repo.all(from p in tab, where: p.code == ^code)
    result1 = Repo.all(from p in tab, where: p.code == ^code and p.version == ^version)
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
      |> Repo.all
    query = from w in tab, where: like(w.code, ^code) or like(w.name, ^code), select: count(w.id)
    count = hd(Repo.all(query))
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
      Enum.map(result, fn x ->
        Map.keys(x) |>Enum.reduce(%{}, fn k, acc -> Map.put(acc, Key.cn(k), Map.get(x, k)) end)|>Map.put(:fileType, filename)
      end)
    %{result: result}
  end

  #搜索
  def rule_search(filename, value, servertype) do
    tab = RuleQuery.tab(servertype, filename)
    #取得要搜索表的表头
    keys =
      case servertype do
        "server" -> Repo.all(from p in tab, limit: 1)
        "block" -> BlockRepo.all(from p in tab, limit: 1)
      end
      |>RuleQuery.del_key(filename, "")|>List.first|>Map.keys
    query_keys = keys -- [:id]
    query = RuleQuery.table(filename, tab)
    query =
      case tab do
        Hitb.Library.LibWt4 ->
          value = "%#{value}%"
          query
          |>where([p], like(p.code, ^value) or like(p.name, ^value) or like(p.year, ^value))
        _ ->
        Enum.reduce(query_keys, query, fn x, acc ->
          value = "%#{value}%"
          acc
          |>or_where([p],  like(field(p, ^x), ^value))
        end)
      end
    result =
      case servertype do
        "server" -> Repo.all(query)
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
    symptoms = Repo.get_by(RuleSymptom, symptom: symptom)
    if symptoms != nil do
      symptoms
      |> RuleSymptom.changeset(%{icd9_a: icd9_a, icd10_a: icd10_a, pharmacy: pharmacy})
      |> Repo.update()
      %{success: true, info: "保存成功"}
    else
      body = %{"symptom" => symptom, "icd9_a" => icd9_a, "icd10_a" => icd10_a, "pharmacy" => pharmacy}
      %RuleSymptom{}
      |> RuleSymptom.changeset(body)
      |> Repo.insert()
      %{success: true, info: "保存成功"}
    end
  end

  def client_save(filename, server_type, username, data, rows, order_type, order) do
    schema = RuleQuery.tab(server_type, filename)
    if(length(data) > 0)do
      [result, _, _, _, _, _, _, _, _, _] = RuleQuery.get_rule(1, "", filename, "", "", "", rows, server_type, order_type, Key.en(order), "", username)
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
          Repo.delete!(x)
        end)
      #判断是否有要添加的
      Enum.reject(data, fn x -> x.id != "" end)
      |>Enum.each(fn x ->
          x = Map.delete(x, :id)|>Map.merge(%{create_user: username, update_user: username})
          case filename do
            "mdc" -> %RuleMdc{}|>RuleMdc.changeset(x)
            "adrg" -> %RuleAdrg{}|>RuleAdrg.changeset(x)
            "drg" -> %RuleDrg{}|>RuleDrg.changeset(x)
            "icd9" -> %RuleIcd9{}|>RuleIcd9.changeset(x)
            "icd10" -> %RuleIcd10{}|>RuleIcd10.changeset(x)
            "中药" -> %ChineseMedicine{}|>ChineseMedicine.changeset(x)
            "中成药" -> %ChineseMedicinePatent{}|>ChineseMedicinePatent.changeset(x)
            "西药" -> %WesternMedicine{}|>WesternMedicine.changeset(x)
            "诊断规则" -> %RuleCdaIcd10{}|>RuleCdaIcd10.changeset(x)
            "手术规则" -> %RuleCdaIcd9{}|>RuleCdaIcd9.changeset(x)
            "检查规则" -> %RuleExamine{}|>RuleExamine.changeset(x)
            "药品规则" -> %RulePharmacy{}|>RulePharmacy.changeset(x)
            "体征规则" -> %RuleSign{}|>RuleSign.changeset(x)
            "症状规则" -> %RuleSymptom{}|>RuleSymptom.changeset(x)
            _ ->
              %LibWt4{}
              |>LibWt4.changeset(Map.merge(x, %{type: filename}))
          end
          |>Repo.insert
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
          att = Repo.get_by(schema, id: x.id)
          att
          |>schema.changeset(x)
          |>Repo.update
        end)
    end
  end

  def client_save2(data, header, type, page, type, filename, version, year, dissect, rows, server_type, order_type, order, username) do
    schema = RuleQuery.tab(server_type, filename)
    if(length(data) > 1)do
      #去掉文件头
      # data = List.delete_at(data, 0)
      #取得表头
      header = header|>Enum.map(fn x -> Key.en(x)|>String.to_atom end)

      #将数组转换为对象
      data =
        Enum.reduce(header, %{}, fn k, acc ->
          field_type = schema.__schema__(:type, k)
          index = Enum.find_index(header, fn ks -> ks == k end)
          value = Enum.at(data, index)
          value =
            cond do
              field_type == {:array, :string} -> String.split(value, "，")|>Enum.reject(fn x -> x in ["", "-"] end)
              k in [:create_user, :update_user] -> username
              true -> value
            end
          Map.put(acc, k, value)
        end)
      [info, id, result] =
        case type do
          "change" ->
            res = Repo.get_by(schema, id: data.id)
              |>schema.changeset(data)
              |>Repo.update
              |>elem(1)
            ["字典更新成功!", res.id, %{}]
          "add" ->
            res = case filename do
              "mdc" -> %RuleMdc{}|>RuleMdc.changeset(data)
              "adrg" -> %RuleAdrg{}|>RuleAdrg.changeset(data)
              "drg" -> %RuleDrg{}|>RuleDrg.changeset(data)
              "icd9" -> %RuleIcd9{}|>RuleIcd9.changeset(data)
              "icd10" -> %RuleIcd10{}|>RuleIcd10.changeset(data)
              "中药" -> %ChineseMedicine{}|>ChineseMedicine.changeset(data)
              "中成药" -> %ChineseMedicinePatent{}|>ChineseMedicinePatent.changeset(data)
              "西药" -> %WesternMedicine{}|>WesternMedicine.changeset(data)
              "诊断规则" -> %RuleCdaIcd10{}|>RuleCdaIcd10.changeset(data)
              "手术规则" -> %RuleCdaIcd9{}|>RuleCdaIcd9.changeset(data)
              "检查规则" -> %RuleExamine{}|>RuleExamine.changeset(data)
              "药品规则" -> %RulePharmacy{}|>RulePharmacy.changeset(data)
              "体征规则" -> %RuleSign{}|>RuleSign.changeset(data)
              "症状规则" -> %RuleSymptom{}|>RuleSymptom.changeset(data)
              _ ->
                %LibWt4{}
                |>LibWt4.changeset(Map.merge(data, %{type: filename}))
            end
            |>Repo.insert
            |>elem(1)
            ["字典新建成功!", res.id, %{create_user: res.create_user, update_user: res.update_user}]
          "delete" ->
            Repo.get_by(schema, id: data.id)
            |>Repo.delete!
            result = client(page, type, filename, version, year, dissect, rows, server_type, order_type, order, "")
            ["字典删除成功!", "-", result]
        end
      Map.merge(result, %{info: info, id: id})
    else
      %{info: "字典操作失败,未知错误!"}
    end
  end

  defp join(header, data) do
    Enum.map(header, fn k -> Map.get(data, k) end)|>Enum.join(",")
  end


end
