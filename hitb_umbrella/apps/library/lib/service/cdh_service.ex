defmodule Library.CdhService do
  # import Ecto
  import Ecto.Query
  alias Hitb.Repo
  alias Hitb.Library.Cdh
  alias Hitb.Page
  alias Library.Key
  alias Block.Library.Cdh, as: BlockCdh
  alias Block.Repo, as: BlockRepo

  def cdh_list() do
    Repo.all(Cdh)
    |>Enum.map(fn x ->
        Map.drop(x, [:__meta__, :__struct__])
      end)
  end

  def channel_cdh_list() do
    Repo.all(Cdh)
    |>Enum.reduce(%{}, fn x, acc ->
        content = x.content|>String.split(" ")|>Enum.reject(fn x -> x == nil end)
        value = Map.get(acc, x.name)
        case value do
          nil -> Map.put(acc, x.name, [content])
          _ -> Map.put(acc, x.name, [content | value])
        end
      end)
  end

  def cdh(page, rows, server_type, order_type, order) do
    order =
      if order == "" do
        "键"
      else
        order
      end
    rows = if(is_integer(rows))do rows else String.to_integer(rows) end
    skip = Page.skip(page, rows)
    query = if(server_type == "server")do from(w in Cdh) else from(w in BlockCdh) end
    count =
      case server_type  do
        "server" -> query|>select([w], count(w.id))|>Repo.all|>List.first
        _ -> query|>select([w], count(w.id))|>BlockRepo.all|>List.first
      end
    order2 = Key.en(order)|>String.to_atom
    query = order_by(query, [w], asc: field(w, ^order2))
      |> limit([w], ^rows)
      |> offset([w], ^skip)
    result =
      case server_type do
        "server" -> query|>Repo.all
        _ -> query|>BlockRepo.all
      end
    result =
      case length(result) do
        0 -> []
        _ ->
          [[], ["键", "值"]] ++ Enum.map(result, fn x -> [:key, :value]|>Enum.map(fn key -> Map.get(x, key) end) end)
      end
    [page_num, page_list, _count_page] = Page.page_list(page, count, rows)
    %{library: result, list: %{time: [], org: [], version: []}, count: count, page_list: page_list, page: page_num, sort_type: order_type, sort_value: order}
  end

end
