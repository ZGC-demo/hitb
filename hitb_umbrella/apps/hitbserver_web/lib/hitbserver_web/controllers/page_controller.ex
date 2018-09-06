defmodule HitbserverWeb.PageController do
  use HitbserverWeb, :controller
  # import Ecto.Query
  alias Server.UserService
  alias Server.UploadService
  # alias Stat.StatCdaService
  plug HitbserverWeb.Access

  def index(conn, _params) do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      %{"page" => page} = Map.merge(%{"page" => "1"}, conn.params)
      render conn, "index.html", user: user, page_num: page
    else
      redirect conn, to: "/hospitals/login"
    end
  end

  def test(conn, _params) do
    Hitb.Repo.all(Hitb.Edit.Cda)
    |>Enum.each(fn x ->
        a = String.split(x.content, ",")
        |>Enum.map(fn k ->
            String.split(k, " ")
          end)
        a = Poison.encode!([["创建时间", "2018-09-05 10:24:33"]])
        x
        |>Hitb.Edit.Cda.changeset(%{header: a})
        |>Hitb.Repo.update

      end)


    # {:ok, file} = File.open "/home/hitb/git/clinet/test_stat_2.json", [:write]
    # {:ok, str} = File.read("/home/hitb/git/clinet/static/test_stat_2.json")
    # a = Poison.decode!(str)
    # |>Enum.map(fn x ->
    #     x = Map.put(x, "org", x["\uFEFForg"])
    #     x = Map.delete(x, "\uFEFForg")
    #   end)
    # # data = String.split(str, "\n") -- [""]
    # # header = data|>List.first|>String.split(",")
    # # data = data|>List.delete_at(0)|>Enum.map(fn x -> String.split(x, ",") end)
    # IO.binwrite file, Poison.encode!(a)
    # data =
    #   Enum.map(data, fn x ->
    #     a = Enum.reduce(header, %{}, fn k, acc ->
    #       index = Enum.find_index(header, fn ks -> ks == k end)
    #       value = Enum.at(x, index)
    #       Map.put(acc, k, value)
    #     end)
    #     Map.put(a, :fileType, "test_wt4_2015年2月")
    #   end)
    # IO.binwrite file, Poison.encode!(data)
    # IO.inspect Poison.encode!(data)
    # |>Enum.each(fn x ->
    #     [icd10_a, pharmacy, symptoms] = String.split(x, "&")
    #     icd10_a = String.split(icd10_a, ",")|>Enum.reject(fn x -> x == "" end)
    #     symptoms = String.split(symptoms, ",")|>Enum.reject(fn x -> x == "" end)
    #     %Hitb.Library.RulePharmacy{}
    #     |>Hitb.Library.RulePharmacy.changeset(%{pharmacy: pharmacy, icd10_a: icd10_a, symptoms: symptoms, create_user: "wangtianao@hitb.com.cn", update_user: "wangtianao@hitb.com.cn"})
    #     |>Hitb.Repo.insert
    # end)


    # {:ok, conn} = Mongo.start_link(url: "mongodb://localhost:27017/test")
    # cursor = Mongo.find(conn, "MedKnow", %{})
    # a = cursor
    # |> Enum.to_list()
    # |> Enum.map(fn x ->
    #     %{"cid" => name, "desc" => desc, "keywords" => keywords} = Map.merge(%{"keywords" => []}, x)
    #     [name, en_name] =
    #       case String.contains? name, "（"  do
    #         true ->
    #           name = String.split(name, "（")
    #           en_name = String.split(name|>List.last, "）")|>List.first
    #           name = name|>List.first
    #           [name, en_name]
    #         false ->
    #           [name, ""]
    #       end
    #     [name, en_name] =
    #       case String.contains? name, "("  do
    #         true ->
    #           name = String.split(name, "(")
    #           en_name = String.split(name|>List.last, ")")|>List.first
    #           name = name|>List.first
    #           [name, en_name]
    #         false ->
    #           [name, ""]
    #       end
    #     # IO.inspect x
    #     %Hitb.Library.MdeKnow{}
    #     |>Hitb.Library.MdeKnow.changeset(%{name: name, en_name: en_name, desc: desc, keywords: keywords, create_user: "duanzhichao@hitb.com.cn", update_user: "duanzhichao@hitb.com.cn"})
    #     |>Hitb.Repo.insert
    #   end)
    #


    # Gets an enumerable cursor for the results
    # cursor = Mongo.find(conn, "MedKnow", %{})
    #
    # a = cursor
    # |> Enum.to_list()
    # |> Enum.map(fn x ->
    #     body = x["body"]
    #     body = Map.delete(body, "item")
    #   end)
    # # b = a|>hd
    # a =
    # Enum.map(a, fn x ->
    #   s = Map.values(x)
    #   |>Enum.reduce("", fn v, acc ->
    #       map = Map.values(v)|>Enum.reject(fn x -> is_map(x) === false end)
    #       c = Enum.reduce(map, v["name"], fn m,acc ->
    #         m = Map.merge(%{"desc" => [], "name" => "", "value" => ""}, m)
    #         if(m["name"] != "")do
    #           desc = m["desc"]|>Enum.join("")
    #           str =
    #             case desc do
    #               "" -> "#{m["name"]} #{m["value"]}"
    #               _ -> "#{m["name"]} #{m["value"]},#{m["name"]} #{desc}"
    #             end
    #         end
    #         "#{acc},#{str}"
    #       end)
    #       case acc do
    #         "" -> "##{c}"
    #         _ -> "#{acc},#{c}"
    #       end
    #     end)
    #   s = Regex.replace(~r/#,/, s, "")
    #   s = Regex.replace(~r/#/, s, "")
    # end)
    # a
    # |>Enum.reject(fn x -> x == "" end)
    # |>Enum.reduce(1, fn x, acc ->
    #     %Hitb.Edit.Cda{}
    #     |>Hitb.Edit.Cda.changeset(%{content: x, name: "病案_#{acc}.cda", patient_id: Edit.CdaService.generate_patient_id(), username: "duanzhichao@hitb.com.cn", is_change: true, is_show: true, header: ""})
    #     |>Hitb.Repo.insert
    #
    #     %Hitb.Edit.CdaFile{}
    #     |>Hitb.Edit.CdaFile.changeset(%{filename: "病案_#{acc}.cda", username: "duanzhichao@hitb.com.cn"})
    #     |>Hitb.Repo.insert
    #     acc = acc + 1
    #   end)

    json conn, %{}
  end

  def chat(conn, _params) do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      %{"page" => page} = Map.merge(%{"page" => "1"}, conn.params)
      render conn, "chat_test.html", user: user, page_num: page
    else
      redirect conn, to: "/hospitals/login"
    end
  end

  def login_html(conn, _params)do
    user = get_session(conn, :user)
    user = UserService.user_info(user)
    render conn, "login.html", user: user
  end

  def login(conn, %{"user" => user}) do
    %{"username" => username, "password" => password} = user
    [user, login] = UserService.login(%{username: username, password: password}, %{})
    conn =
      case login do
        false ->
          put_session(conn, :user, %{login: false, username: "", type: 2, key: []})
        true ->
          put_session(conn, :user, %{id: user.id, login: login, username: username, type: user.type, key: user.key})
      end
    json conn, %{login: true, username: username}
  end

  def logout(conn, _params) do
    user = UserService.logout()
    conn = put_session(conn, :user, user)
    redirect conn, to: "/hospitals/login"
  end

  def wt4_upload(conn, _params) do
    wt4s = UploadService.wt4_upload(conn)
    json conn, wt4s
  end

  def wt4_insert(conn, _params) do
    wt4s = UploadService.wt4_insert()
    json conn, wt4s
  end

  def share(conn, _params) do
    user = get_session(conn, :user)
    login = UserService.is_login(user)
    if(login)do
      %{"page" => page} = Map.merge(%{"page" => "1"}, conn.params)
      render conn, "share.html", user: user, page_num: page
    else
      redirect conn, to: "/hospitals/login"
    end
  end
  def connect(conn, _params) do
    json conn, %{success: true}
  end
end
