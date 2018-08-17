defmodule HitbserverWeb.RuleController do
  use HitbserverWeb, :controller
  # alias Server.UserService
  alias Library.RuleService
  alias Library.CdhService
  alias Library.RuleCdaStatService
  plug HitbserverWeb.Access
  plug :put_layout, "app_stat.html"

  def rule(conn, _params) do
    %{"page" => page, "type" => type, "tab_type" => tab_type, "version" => version, "year" => year, "dissect" => dissect, "rows" => rows, "order_type" => order_type, "order" => order} = Map.merge(%{"page" => "1", "type" => "year", "tab_type" => "mdc", "version" => "BJ", "year" => "", "dissect" => "", "rows" => 15, "order_type" => "asc", "order" => "code"}, conn.params)
    order =
      cond do
        tab_type == "western_medicine" and order == "code" -> "en_name"
        tab_type == "cdh" and order == "code" -> "key"
        true -> order
      end
    result = RuleService.json(page, type, tab_type, version, year, dissect, rows, order_type, order)
    json conn, result
  end

  def rule_file(conn, _params) do
    %{"server_type" => server_type} = Map.merge(%{"server_type" => "server"}, conn.params)
    file = RuleService.file(server_type)
    json conn, %{data: file}
  end

  def rule_client(conn, _params) do
    %{"page" => page, "type" => type, "tab_type" => tab_type, "version" => version, "year" => year, "dissect" => dissect, "rows" => rows, "server_type" => server_type, "order_type" => order_type, "order" => order, "username" => username} = Map.merge(%{"page" => "1", "type" => "year", "tab_type" => "mdc", "version" => "BJ", "year" => "", "dissect" => "", "rows" => 15, "server_type" => "server", "order_type" => "asc", "order" => "编码", "username" => ""}, conn.params)
    rows =
      case is_integer(rows) do
        true -> rows
        _ -> String.to_integer(rows)
      end
    order =
      cond do
        tab_type == "西药" and order == "编码" -> "英文名称"
        tab_type == "cdh" and order == "编码" -> "键"
        true -> order
      end
    server_type = if(server_type == "undefined")do "server" else server_type end
    result =
      case tab_type do
        "cdh" ->
          CdhService.cdh(page, rows, server_type, order_type, order)
        _ ->
          RuleService.client(page, type, tab_type, version, year, dissect, rows, server_type, order_type, order, username)
          # RuleService.client/
      end
    json conn, result
  end

  def contrast(conn, %{"table" => table, "id" => id}) do
    result = RuleService.contrast(table, id)
    json conn, result
  end

  def details(conn, %{"code" => code, "table" => table, "version" => version}) do
    result = RuleService.details(code, table, version)
    json conn, result
  end
# 模糊搜索
  def search(conn, _params) do
    %{"page" => page, "table" => table, "code" => code} = Map.merge(%{"page" => "1", "table" => "", "code" => ""}, conn.params)
    result = RuleService.search(page, table, code)
    json conn, result
  end
  # 字典库下载
  def rule_down(conn, %{"filename" => filename}) do
    result = RuleService.download(filename)
    json conn, result
  end
  # 客户端模糊搜索
  def rule_search(conn, _params) do
    %{"filename" => filename, "value" => value, "servertype" => servertype} = Map.merge(%{"filename" => "", "value" => "", "servertype" => ""}, conn.params)
    result = RuleService.rule_search(filename, value, servertype)
    json conn, result
  end
  #??????????
  def rule_symptom(conn, _params) do
    %{"symptom" => symptom, "icd9_a" => icd9_a, "icd10_a" => icd10_a, "pharmacy" => pharmacy } = Map.merge(%{"symptom" => "上腹痛", "icd9_a" => [], "icd10_a" => [], "pharmacy" => ["消化系溃疡"]}, conn.params)
    symptom = Poison.decode!(symptom)
    RuleService.rule_symptom(symptom, icd9_a, icd10_a, pharmacy)
    json conn, %{}
  end

  #帮助查询
  def symptom_serach(conn, _params) do
    %{"symptom" => symptom, "section" => section} = Map.merge(%{"symptom" => []}, conn.params)
    symptom = Poison.decode!(symptom)|>hd()
    result = RuleCdaStatService.symptom_serach(symptom, section)
    json conn, %{result: result}
  end

  #客户端规则保存
  def client_save(conn, _params) do
    %{"data" => data, "rows" => rows, "server_type" => server_type, "order_type" => order_type, "order" => order, "tab_type" => tab_type, "username" => username} = Map.merge(%{"data" => "[\"\",\"症状集,编码,名称,版本,年份\",\"AA1111111,AA19,心脏移植,BJ,2017\",\"AA1,AA19,心脏移植,BJ,2014\",\"AA1,AA19,心脏移植,CC,2016\",\"AA1,AA19,心脏移植,BJ,2016\",\"AA1,AA19,心脏移植,GB,2017\",\"AA1,AA19,心脏移植,CC,2015\",\"AA1,AA19,心脏移植,BJ,2015\",\"AA1,AA19,心脏移植,CN,2017\",\"AB1,AB19,肝移植,BJ,2016\",\"AB1,AB19,肝移植,GB,2017\",\"AB1,AB19,肝移植,CC,2015\",\"AB1,AB19,肝移植,BJ,2015\",\"AB1,AB19,肝移植,BJ,2014\",\"AB1,AB19,肝移植,BJ,2017\",\"AB1,AB19,肝移植,CC,2016\",\"AB1,AB19,肝移植,CN,2017\",\"AC1,AC19,胰/肾同时移植,GB,2017\",\"AC1,AC19,胰/肾同时移植,BJ,2016\",\"AC1,AC19,胰/肾同时移植,BJ,2015\",\"AC1,AC19,胰/肾同时移植,CC,2016\",\"AC1,AC19,胰/肾同时移植,CC,2015\",\"AC1,AC19,胰/肾同时移植,BJ,2017\",\"AC1,AC19,胰/肾同时移植,BJ,2014\",\"AC1,AC19,胰/肾同时移植,CN,2017\",\"AD1,AD19,胰腺移植,CC,2015\",\"AD1,AD19,胰腺移植,CN,2017\",\"AD1,AD19,胰腺移植,GB,2017\",\"AD1,AD19,胰腺移植,BJ,2014\",\"AD1,AD19,胰腺移植,BJ,2017\",\"AD1,AD19,胰腺移植,BJ,2016\"]", "rows" => 30, "server_type" => "server", "order_type" => "asc", "order" => "编码", "tab_type" => "诊断规则", "username" => ""}, conn.params)
    order =
      cond do
        tab_type == "西药" and order == "编码" -> "英文名称"
        tab_type == "cdh" and order == "编码" -> "键"
        true -> order
      end
    data = Poison.decode!(data)
    RuleService.client_save(tab_type, server_type, username, data, rows, order_type, order)
    json conn, %{result: true}
  end
end
