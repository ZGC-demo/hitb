
defmodule HitbserverWeb.CdaControllerTest do
  use HitbserverWeb.ConnCase
  alias Hitb.Edit.Cda
  alias Hitb.Repo
  @valid_attrs %Cda{content: "sss", name: "sss", username: "sss", is_show: false, is_change: false}

  # test "GET /cda_user", %{conn: conn} do
  #   conn = get conn, "/edit/cda_user/?server_type='server'"
  #   assert json_response(conn, 200)["info"] == "读取成功"
  # end
  test "GET /cda_file", %{conn: conn} do
    conn = get conn, "/edit/cda_file/?username='server'＆server_type"
    assert json_response(conn, 200)["info"] == "读取成功"
  end
  test "POST /cda_consule", %{conn: conn} do
    conn = post conn, "/edit/cda_consule", diag: []
    assert json_response(conn, 200) == %{"cda" => []}
  end
  test "GET /cda", %{conn: conn} do
    conn = get conn, "/edit/cda?filename='sss'&username='sss'"
    assert json_response(conn, 200)["info"] == ["文件读取失败,无此文件"]
  end
  test "POST /cda", %{conn: conn} do
    cda = Repo.insert!(@valid_attrs)
    conn = post conn, "/edit/cda", id: cda.id, content: "content", file_name: "file_name", username: "username", doctype: "doctype", mouldtype: "mouldtype", header: %{"a" =>"a", "b"=>"n"}
    assert json_response(conn, 200)["info"] == "新建成功"
  end

end
# defmodule EditWeb.CdaControllerTest do
#   use EditWeb.ConnCase
#
#   alias Edit.Client
#   alias Edit.Client.Cda
#
#   @create_attrs %{content: "some content", name: "some name", username: "some username"}
#   @update_attrs %{content: "some updated content", name: "some updated name", username: "some updated username"}
#   @invalid_attrs %{content: nil, name: nil, username: nil}
#
#   def fixture(:cda) do
#     {:ok, cda} = Client.create_cda(@create_attrs)
#     cda
#   end
#
#   setup %{conn: conn} do
#     {:ok, conn: put_req_header(conn, "accept", "application/json")}
#   end
#
#   describe "index" do
#     test "lists all cda", %{conn: conn} do
#       conn = get conn, cda_path(conn, :index)
#       assert json_response(conn, 200)["data"] == []
#     end
#   end
#
#   describe "create cda" do
#     test "renders cda when data is valid", %{conn: conn} do
#       conn = post conn, cda_path(conn, :create), cda: @create_attrs
#       assert %{"id" => id} = json_response(conn, 201)["data"]
#
#       conn = get conn, cda_path(conn, :show, id)
#       assert json_response(conn, 200)["data"] == %{
#         "id" => id,
#         "content" => "some content",
#         "name" => "some name",
#         "username" => "some username"}
#     end
#
#     test "renders errors when data is invalid", %{conn: conn} do
#       conn = post conn, cda_path(conn, :create), cda: @invalid_attrs
#       assert json_response(conn, 422)["errors"] != %{}
#     end
#   end
#
#   describe "update cda" do
#     setup [:create_cda]
#
#     test "renders cda when data is valid", %{conn: conn, cda: %Cda{id: id} = cda} do
#       conn = put conn, cda_path(conn, :update, cda), cda: @update_attrs
#       assert %{"id" => ^id} = json_response(conn, 200)["data"]
#
#       conn = get conn, cda_path(conn, :show, id)
#       assert json_response(conn, 200)["data"] == %{
#         "id" => id,
#         "content" => "some updated content",
#         "name" => "some updated name",
#         "username" => "some updated username"}
#     end
#
#     test "renders errors when data is invalid", %{conn: conn, cda: cda} do
#       conn = put conn, cda_path(conn, :update, cda), cda: @invalid_attrs
#       assert json_response(conn, 422)["errors"] != %{}
#     end
#   end
#
#   describe "delete cda" do
#     setup [:create_cda]
#
#     test "deletes chosen cda", %{conn: conn, cda: cda} do
#       conn = delete conn, cda_path(conn, :delete, cda)
#       assert response(conn, 204)
#       assert_error_sent 404, fn ->
#         get conn, cda_path(conn, :show, cda)
#       end
#     end
#   end
#
#   defp create_cda(_) do
#     cda = fixture(:cda)
#     {:ok, cda: cda}
#   end
# end
