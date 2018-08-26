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
end
