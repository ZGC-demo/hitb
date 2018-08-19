defmodule Block.LibraryServiceTest do
  # use ExUnit.Case
  use Block.DataCase, async: true
  alias Block.LibraryService
  # @cda_file %{username: "sss", filename: "sss", hash: "ssss", previous_hash: "ssss"}
  # @cda %{content: "sss", name: "sss", username: "sss", is_show: false, is_change: false}

  test "test get_last get_cdh" do
    assert LibraryService.get_last("cdh", "")
  end

  test "test get_last get_ruleadrg" do
    assert LibraryService.get_last("rule_adrg", "")
  end

  test "test get_last get_ruledrg" do
    assert LibraryService.get_last("rule_drg", "")
  end

  test "test get_last get_ruleicd9" do
    assert LibraryService.get_last("rule_icd9", "")
  end

  test "test get_last get_ruleicd10" do
    assert LibraryService.get_last("rule_icd10", "")
  end

  test "test get_last get_chinese_medicine" do
    assert LibraryService.get_last("chinese_medicine", "")
  end

  test "test get_last get_chinese_medicine_patent" do
    assert LibraryService.get_last("chinese_medicine_patent", "")
  end

  test "test get_last get_lib_wt4" do
    assert LibraryService.get_last("lib_wt4", "")
  end





  test "test get_rulemdcs" do
    assert LibraryService.get_all("rule_mdc")
  end

  test "test get_ruleadrgs" do
    assert LibraryService.get_all("rule_adrg")
  end

  test "test get_ruledrgs" do
    assert LibraryService.get_all("rule_drg")
  end

  test "test get_ruleicd9s" do
    assert LibraryService.get_all("rule_icd9")
  end

  test "test get_ruleicd10s" do
    assert LibraryService.get_all("rule_icd10")
  end

  test "test get_chinese_medicines" do
    assert LibraryService.get_all("chinese_medicine")
  end

  test "test get_chinese_medicine_patents" do
    assert LibraryService.get_all("chinese_medicine_patent")
  end

  test "test get_lib_wt4s" do
    assert LibraryService.get_all("lib_wt4")
  end








  test "test get_rulemdc_num" do
    assert LibraryService.get_num("rule_mdc")
  end

  test "test get_ruleadrg_num" do
    assert LibraryService.get_num("rule_adrg")
  end

  test "test get_ruledrg_num" do
    assert LibraryService.get_num("rule_drg")
  end

  test "test get_ruleicd9_num" do
    assert LibraryService.get_num("rule_icd9")
  end

  test "test get_ruleicd10_num" do
    assert LibraryService.get_num("rule_icd10")
  end

  test "test get_chinese_medicine_num" do
    assert LibraryService.get_num("chinese_medicine")
  end

  test "test get_chinese_medicine_patent_num" do
    assert LibraryService.get_num("chinese_medicine_patent")
  end

  test "test get_lib_wt4_num" do
    assert LibraryService.get_num("lib_wt4")
  end

end
