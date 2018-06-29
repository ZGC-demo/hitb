defmodule Edit.CdaService do
  # import Ecto
  import Ecto.Query
  alias Hitb.Repo, as: HitbRepo
  alias Block.Repo, as: BlockRepo
  alias Hitb.Edit.Cda, as: HitbCda
  alias Hitb.Edit.CdaFile, as: HitbCdaFile
  alias Block.Edit.CdaFile, as: BlockCdaFile
  alias Block.Edit.Cda, as: BlockCda
  alias Hitb.Edit.MyMould
  alias Hitb.Time
  alias Hitb.Server.User
  alias Edit.PatientService

  def cda_user(server_type) do
    cda_users =
      case server_type do
        "server" -> HitbRepo.all(from p in HitbCdaFile, select: p.username)|>:lists.usort
        _ -> BlockRepo.all(from p in BlockCdaFile, select: p.username)|>:lists.usort
      end
    users = HitbRepo.all(from p in User, where: p.is_show == false, select: p.username)
    users = if(users)do users else [] end
    [cda_users -- users, "读取成功"]
  end

  def cda_files(username, server_type) do
    cond do
      server_type == "block" ->
        [BlockRepo.all(from p in BlockCda, select: [p.username, p.name]) |> Enum.map(fn x -> Enum.join(x, "-") end), "读取成功"]
      username == "" ->
        [HitbRepo.all(from p in HitbCda, select: [p.username, p.name]) |> Enum.map(fn x -> Enum.join(x, "-") end), "读取成功"]
      true ->
        [HitbRepo.all(from p in HitbCda, where: p.username == ^username, select: [p.username, p.name]) |> Enum.map(fn x -> Enum.join(x, "-") end), "读取成功"]
    end
  end

  def cda_file(filename, username) do
    edit = HitbRepo.get_by(HitbCda, username: username, name: filename)
    cond do
      edit == nil ->
        [[],["文件读取失败,无此文件"]]
      edit.is_show == false ->
        [[],["文件拥有者不允许他人查看,请联系文件拥有者"]]
      edit.is_change == false ->
        [Map.drop(edit, [:__meta__, :__struct__, :id]),["文件读取成功,但文件拥有者不允许修改"]]
      true ->
        [Map.drop(edit, [:__meta__, :__struct__]), ["文件读取成功"]]
    end
  end

  def update(id, content, file_name, username, doctype, mouldtype, header, save_type) do
    {file_username, file_name} =
      if(String.contains? file_name, "-")do
        List.to_tuple(String.split(file_name, "-"))
      else
        {username, file_name}
      end
    if (mouldtype == "模板") do
      myMoulds(file_name, file_username, content, doctype, header, save_type)
    else
      times = Time.stime_number()
      PatientService.patient_insert(content, username, times)
      myCdas(id, file_name, file_username, content, doctype, username, times, header, save_type)
    end
  end

  def consule(cda_info) do
    cda_info =
      Enum.reject(cda_info, fn x ->
        cond do
          x == "" -> true
          String.contains? x, "省" -> true
          String.contains? x, "市" -> true
          String.contains? x, "县" -> true
          String.contains? x, "区" -> true
          String.contains? x, "街" -> true
          String.contains? x, "乡" -> true
          String.contains? x, "镇" -> true
          String.contains? x, "族" -> true
          String.contains? x, "国" -> true
          String.contains? x, "-" -> true
          x in ["有", "无"] -> true
          x in ["否", "是"] -> true
          x in ["男","女"] -> true
          x in ["已婚", "未婚", "离异"] -> true
          x == "配偶" -> true
          is_num(x) -> true
          true -> false
        end
      end)
    query = from(p in HitbCda)
    Enum.reduce(cda_info, query, fn x, acc ->
      x = "%#{x}%"
      acc
      |>or_where([p],  like(p.content, ^x))
    end)
    |>HitbRepo.all
    |>:lists.usort
    |>Enum.map(fn x -> x.content end)
  end

  defp is_num(x) do
    x2 =
      try do
        String.to_integer(x)
      rescue
        _ ->
          try do
            String.to_float(x)
          rescue
            _ -> x
          end
      end
    case x == x2 do
      true -> false
      false -> true
    end
  end

  defp myMoulds(file_name, file_username, content, doctype, header, save_type) do
    mymould = HitbRepo.get_by(MyMould, name: file_name, username: file_username)
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
      |> HitbRepo.update()
      %{success: true, info: "保存成功"}
    else
      namea = doctype<>".cdh"
      body = %{"content" => content, "name" => namea, "username" => file_username, "is_change" => true, "is_show" => true, "header" => header}
      %MyMould{}
      |> MyMould.changeset(body)
      |> HitbRepo.insert()
      %{success: true, info: "新建成功"}
    end
  end

  defp myCdas(id, _file_name, file_username, content, doctype, username, patient_id, header, save_type) do
    header = Enum.reduce(Map.keys(header), "", fn x, acc ->
      if acc == "" do
        "#{acc}#{x}:#{Map.get(header,x)}"
      else
        "#{acc};#{x}:#{Map.get(header,x)}"
      end
    end)
    cond do
      save_type in ["上传", "新建"] ->
        %HitbCda{}
        |> HitbCda.changeset(%{"content" => content, "name" => "#{doctype}_#{Time.stime_number}.cda", "username" => file_username, "is_change" => false, "is_show" => true, "patient_id" => patient_id, "header" => header})
        |> HitbRepo.insert()
        %{success: true, info: "#{save_type}成功"}
      id != "" ->
        cda = HitbRepo.get_by(HitbCda, id: id)
        cond do
          username == file_username ->
            HitbRepo.get!(HitbCda, id)
            |>HitbCda.changeset(%{content: content, header: header})
            |>HitbRepo.update
            %{success: true, info: "保存成功"}
          cda.is_change == false ->
            %{success: false, info: "用户设置该文件不允许其他用户修改,请联系该文件拥有者"}
          true ->
            HitbRepo.get!(HItbCda, id)
            |>HitbCda.changeset(%{content: content, header: header})
            |>HitbRepo.update
            %{success: true, info: "保存成功"}
        end
    end
  end
end
