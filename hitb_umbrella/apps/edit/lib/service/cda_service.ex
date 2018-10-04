defmodule Edit.CdaService do
  # import Ecto
  import Ecto.Query
  alias Hitb.Repo
  alias Block.Repo, as: BlockRepo
  alias Hitb.Edit.Cda, as: HitbCda
  alias Hitb.Edit.CdaFile, as: HitbCdaFile
  alias Hitb.Library.Cdh, as: HitbCdh
  alias Block.Library.Cdh, as: BlockCdh
  alias Block.Edit.CdaFile, as: BlockCdaFile
  alias Block.Edit.Cda, as: BlockCda
  alias Hitb.Server.User
  alias Hitb.Edit.MyMould

  def cda_count(username) do
    user = Repo.all(from p in HitbCda, where: p.username == ^username, select: count(p.id))|>List.first
    server = Repo.all(from p in HitbCda, select: count(p.id))|>List.first
    block = BlockRepo.all(from p in BlockCda, select: count(p.id))|>List.first
    %{user: user, server: server, block: block}
  end

  defp cda_user(server_type) do
    cda_users =
      case server_type do
        "server" -> Repo.all(from p in HitbCdaFile, group_by: p.username, select: %{value: p.username, count: count(p.id)})|>:lists.usort
        _ -> BlockRepo.all(from p in BlockCdaFile, group_by: p.username, select: %{value: p.username, count: count(p.id)})|>:lists.usort
      end
    users = Repo.all(from p in User, where: p.is_show == false, select: p.username)
    Enum.reject(cda_users, fn x -> x.value in users end)
    # |>Enum.map(fn x -> "#{x.username}----------------------#{x.count}" end)
  end

  defp cda_customer(server_type) do
    case server_type do
      "server" -> Repo.all(from p in HitbCda, group_by: p.patient_id, select: %{value: p.patient_id, count: count(p.id)})|>:lists.usort
      _ -> BlockRepo.all(from p in BlockCda, group_by: p.patient_id, select: %{value: p.patient_id, count: count(p.id)})|>:lists.usort
    end
    # |>Enum.map(fn x -> "#{x.patient_id}----------------------#{x.count}" end)
  end

  def cda_files(_username, type, server_type) do
    res =
      case type do
        "user" -> cda_user(server_type)
        "customer" ->  cda_customer(server_type)
        "file" -> Repo.all(from p in HitbCda, group_by: p.type, select: %{value: p.type, count: count(p.id)})|>:lists.usort
        "model" -> Repo.all(from p in MyMould, group_by: p.name, select: %{value: p.name, count: count(p.id)})|>:lists.usort
      end
    # cond do
    #   server_type == "block" ->
    #     [BlockRepo.all(from p in BlockCda, select: [p.username, p.name]) |> Enum.map(fn x -> Enum.join(x, "-") end), "读取成功"]
    #   username == "" ->
    #     [Repo.all(from p in HitbCda, select: [p.username, p.name]) |> Enum.map(fn x -> Enum.join(x, "-") end), "读取成功"]
    #   true ->
    #     [Repo.all(from p in HitbCda, where: p.username == ^username, select: [p.username, p.name]) |> Enum.map(fn x -> Enum.join(x, "-") end), "读取成功"]
    # end
    [res, "读取成功"]
  end

  def cda_file(file_name, type, username) do
    case type do
      "user" -> [Repo.all(from p in HitbCdaFile, select: p.filename, where: p.username == ^file_name), ["文件列表读取成功"]]
      "customer" -> [Repo.all(from p in HitbCda, select: p.name, where: p.patient_id == ^file_name), ["文件列表读取成功"]]
      "file" -> [Repo.all(from p in HitbCda, select: p.name, where: p.type == ^file_name), ["文件列表读取成功"]]
      "model" ->
        [Repo.all(from p in MyMould, select: %{name: p.name, username: p.username}, where: p.name == ^file_name)|>Enum.map(fn x -> "#{x.username}-#{x.name}" end), ["文件列表读取成功"]]
      "content" ->
        edit = Repo.get_by(HitbCda, username: username, name: file_name)
        cond do
          edit == nil ->
            [%{header: "", content: ""}, ["文件读取失败,无此文件"]]
          edit.is_show == false ->
            [%{header: "", content: ""}, ["文件拥有者不允许他人查看,请联系文件拥有者"]]
          edit.is_change == false ->
            edit = %{edit | :header => Poison.decode!(edit.header), :content => Poison.decode!(edit.content)}
            [Map.drop(edit, [:__meta__, :__struct__, :id]),["文件读取成功,但文件拥有者不允许修改"]]
          true ->
            edit = %{edit | :header => Poison.decode!(edit.header), :content => Poison.decode!(edit.content)}
            [Map.drop(edit, [:__meta__, :__struct__]), ["文件读取成功"]]
        end
    end
  end

  def update(content, file_name, username, doctype, header, save_type, mouldtype) do
    [file_username, file_name] = String.split(file_name, "-")
    if (mouldtype == "模板") do
      myMoulds(file_name, username, content, doctype, header, save_type)
    else
      %{"上传时间" => header1, "下载时间" => header2, "保存时间" => header3, "修改时间" => header4, "创建时间" => header5, "发布时间" => header6, "标题" => header7, "病人" => header8} = header
      header = [["上传时间", header1], ["下载时间", header2], ["保存时间", header3], ["修改时间", header4], ["创建时间", header5], ["发布时间", header6], ["标题", header7], ["病人", header8]]
      cda = Repo.get_by(HItbCda, name: file_name,  username: file_username)
      case cda do
        nil ->
          patient_id = generate_patient_id()
          %HitbCda{}
          |> HitbCda.changeset(%{"content" => content, "name" => "#{file_name}", "username" => file_username, "is_change" => false, "is_show" => true, "patient_id" => patient_id, "header" => header})
          |> Repo.insert()
          %{success: true, info: "保存成功"}
        _ ->
          if(file_username == username)do
            cda
            |>HitbCda.changeset(%{content: content, header: header})
            |>Repo.update
            %{success: true, info: "保存成功"}
          else
            patient_id = generate_patient_id()
            %HitbCda{}
            |> HitbCda.changeset(%{"content" => content, "name" => "#{file_name}", "username" => username, "is_change" => false, "is_show" => true, "patient_id" => patient_id, "header" => header})
            |> Repo.insert()
            %{success: true, info: "保存成功"}
          end
      end
    end
    %{success: true, info: "测试"}
  end

  defp myMoulds(file_name, file_username, content, _doctype, header, _save_type) do
    mymould = Repo.get_by(MyMould, name: "#{file_name}", username: file_username)
    header = Enum.reduce(Map.keys(header), "", fn x, acc ->
      if acc == "" do
        "#{acc}#{x}:#{Map.get(header,x)}"
      else
        "#{acc};#{x}:#{Map.get(header,x)}"
      end
    end)
    if(mymould)do
      mymould
      |> MyMould.changeset(%{content: content, header: header})
      |> Repo.update()
      %{success: true, info: "保存成功"}
    else
      namea = "#{file_name}"
      body = %{"content" => content, "name" => namea, "username" => file_username, "is_change" => true, "is_show" => true, "header" => header}
      %MyMould{}
      |> MyMould.changeset(body)
      |> Repo.insert()
      %{success: true, info: "新建成功"}
    end
  end

  def generate_patient_id() do
    {megaSecs, secs, _} = :erlang.timestamp()
    randMegaSecs = :rand.uniform(megaSecs)
    randSecs = :rand.uniform(secs)
    randSec = :os.system_time(:seconds)
    [randSec, randSecs, randMegaSecs] |> Enum.map(fn x -> to_string(x) end) |> Enum.join("")
  end

  def cdh_control(key, value, username) do
    cdh = Repo.get_by(HitbCdh, key: key, username: username)
    result =
      if (cdh) do
        "该条已经存在"
      else
        %HitbCdh{}
        |> HitbCdh.changeset(%{"key" => key,  "value" => value, "username" => username})
        |> Repo.insert()
        "添加成功"
      end
    %{result: result}
  end

  def cdh_count(username) do
    user = Repo.all(from p in HitbCdh, where: p.username == ^username, select: count(p.id))|>List.first
    server = Repo.all(from p in HitbCdh, select: count(p.id))|>List.first
    block = BlockRepo.all(from p in BlockCdh, select: count(p.id))|>List.first
    %{user: user, server: server, block: block}
  end
end
