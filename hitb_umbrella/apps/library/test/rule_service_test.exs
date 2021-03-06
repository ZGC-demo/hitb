defmodule Library.RuleServiceTest do
  use Hitb.DataCase, async: true
  alias Library.RuleService
  alias Library.RuleCdaStatService

  test "test rule" do
    assert RuleService.json(1, "year", "mdc", "BJ", "", "", 15, "code", "asc") == %{dissect: "", page_list: [], page_num: 1, result: [], tab_type: "mdc", type: "year", version: "BJ", year: "", list: %{org: ["全部"], time: ["全部"], version: ["全部"]}}
  end

  test "test file" do
    assert RuleService.file('server') == []
  end

  test "test client" do
    assert RuleService.client(1, "year", "mdc", "BJ", "", "", 1, "server", "asc", "code", "") == %{count: 0, library: [], list: %{org: ["全部"], time: ["全部"], version: ["全部"]}, page: 1, page_list: [], order: "code", order_type: "asc"}
  end

  test "test contrast" do
    assert RuleService.contrast("icd9", "123-456") == %{contrast: [], result: [], table: "icd9"}
  end

  test "test details" do
    assert RuleService.details("MDCA", "mdc", "BJ") == %{result: [], table: "mdc", result1: nil}
  end

  test "test search" do
    assert RuleService.search(1, "mdc", "MDCA") == %{table: [], page_list: [], page_num: 1}
  end

  test "test symptom_serach" do
    assert RuleCdaStatService.symptom_serach("key", "section") == %{section: "section"}
  end
end
