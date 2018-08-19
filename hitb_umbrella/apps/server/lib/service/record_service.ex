defmodule Server.RecordService do
  import Ecto.Query
  alias Hitb.Repo
  alias Hitb.Server.Record
  alias Hitb.Time

  def list_record(page, rows) do
    skip = Hitb.Page.skip(page, rows)
    query = from(w in Record)
      |>limit([w], ^rows)
      |>offset([w], ^skip)
      |>Repo.all
      |>Enum.map(fn x ->
          Map.put(x, :datetime, Time.stime_ecto(x.inserted_at))
        end)
    count = hd(Repo.all(from p in Record, select: count(p.id)))
    [count, query]
  end

  def create_record(attrs \\ %{}) do
    %Record{}
    |> Record.changeset(attrs)
    |> Repo.insert()
  end

  def get_record!(id), do: Repo.get!(Record, id)

  def delete_record(id) do
    record = get_record!(id)
    Repo.delete(record)
  end

end
