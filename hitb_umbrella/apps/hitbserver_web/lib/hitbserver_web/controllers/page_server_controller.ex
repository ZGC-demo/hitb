defmodule HitbserverWeb.PageServerController do
  use HitbserverWeb, :controller
  alias Server.UserService
  alias Hitb.Province
  # alias Hitb.Library.EnglishMedicine
  alias Hitb.FileService
  plug HitbserverWeb.Access


  def org_set(conn, _params) do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      render conn, "org_set.html", user: user
    else
      redirect conn, to: "/hospitals/login"
    end
  end

  def department(conn, _params) do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      %{"page" => page} = Map.merge(%{"page" => "1"}, conn.params)
      render conn, "department.html", user: user, page: page
    else
      redirect conn, to: "/hospitals/login"
    end
  end

  def add(conn, %{"type" => type})do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      org = UserService.user_info(user).org
      render conn, "add.html", user: user, type: type, org: org
    else
      redirect conn, to: "/hospitals/login"
    end
  end

  def server_edit(conn, %{"type" => type, "id" => id})do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      org = UserService.user_info(user).org
      render conn, "edit.html", user: user, type: type, org: org, id: id
    else
      redirect conn, to: "/hospitals/login"
    end
  end

  def user_html(conn, _params)do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      %{"page" => page} = Map.merge(%{"page" => "1"}, conn.params)
      render conn, "user_html.html", user: user, page_num: page
    else
      redirect conn, to: "/hospitals/login"
    end
  end

  def comp_info(conn, _params)do
    user = get_session(conn, :user)
    render conn, "comp_info.html",user: user
  end

  def record(conn, _params)do
    %{"page" => page} = Map.merge(%{"page" => "1"}, conn.params)
    user = get_session(conn, :user)
    render conn, "record.html", user: user, page: page
  end

  def myset(conn, _params) do
    %{"type" => type} = Map.merge(%{"type" => "info"}, conn.params)
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      render conn, "myset.html", user: user, type: type
    else
      redirect conn, to: "/hospitals/login"
    end
  end

  def upload_html(conn, _params)do
    user = get_session(conn, :user)
    render conn, "upload.html", user: user
  end

  def upload_html2(conn, _params)do
    user = get_session(conn, :user)
    render conn, "upload2.html", user: user
  end

  def comp_html(conn, _params) do
    user = get_session(conn, :user)
    render conn, "comp_html.html", user: user
  end

  def auditing_html(conn, _params) do
    user = get_session(conn, :user)
    render conn, "auditing.html", user: user
  end

  def doctors(conn, _params) do
    user = get_session(conn, :user)
    render conn, "doctors_html.html", user: user
  end

  def province(conn, _params)do
    json conn, %{province: Province.province(), city: Province.city(), county: Province.county()}
  end
  def json_check(conn, %{"file_path" => file_path})do
    file_json = FileService.check(file_path)
    Hitb.ets_insert(:json, :json, file_json)
    # ConCache.put(:json, :json, file_json)
    json conn, %{result: true}
  end
  def check_html(conn, %{"page" => page})do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      # SchemaHospitals.butying_insert("WT4检查", user.username)
      #求skip
      skip = Hitb.Page.skip(page, 15)
      #求json
      [json, _, count] = get_json(skip)
      #求分页列表
      [page_num, page_list, _count] = Hitb.Page.page_list(page, count, 15)
      file_info = Map.merge(%{:count => count}, Hitb.ets_get(:json, :file_info))
      json =
        Enum.map(json, fn x ->
          case x do
            nil -> []
            _ -> x
          end
        end)
      json = List.flatten(json)
      render conn, "check.html", user: user, file_info: file_info, json: json, page_num: page_num, page_list: page_list
    else
      redirect conn, to: "/login"
    end
  end

  defp get_json(skip) do
    #定义每页条目数量
    num = 15
    jsons = Hitb.ets_get(:json, :json)
    json = Enum.map(skip..skip+num, fn x -> Enum.at(jsons, x) end)
    [json, skip, length(jsons)]
  end
  # def test(conn, _params) do
  #   path = "/home/hitb/桌面/未命名文件夹 2/西药 (复件).csv"
  #   {:ok, arr} = File.read(path)
  #   arrs = String.split(arr, "\n") -- [""]
  #   Enum.each(arrs, fn x ->
  #     [first_level, second_level, third_level, zh_name, en_name, dosage_form, reimbursement_restrictions] = String.split(x, ",")
  #     body = %{"first_level" => first_level, "second_level" => second_level, "third_level" => third_level, "zh_name" =>zh_name, "en_name" => en_name, "dosage_form" => dosage_form, "reimbursement_restrictions" => reimbursement_restrictions}
  #     %EnglishMedicine{}
  #     |> EnglishMedicine.changeset(body)
  #     |> HItb.Repo.insert()
  #   end)
  #   json conn, %{}
  # end
end
