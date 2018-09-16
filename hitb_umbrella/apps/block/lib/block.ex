defmodule Block do
  alias Block.DataRecord
  alias Block.Repo
  @moduledoc """
  Documentation for Block.
  """
  def hello do
    :world
  end

  def genesisBlock do
    :block
  end

  #数据日志
  def create_data_record(attrs, changeset, table) do
    if(changeset.errors == [])do
      data = Poison.encode!(changeset.changes)
      data_record =
        case attrs.id do
          nil -> %{type: "create", table: table, data: data, hash: hash(data)}
          _ -> %{type: "update", table: table, data: data, hash: hash(data)}
        end
      # IO.inspect data_record
      # IO.inspect %DataRecord{}
      # |>DataRecord.changeset(data_record)
      %DataRecord{}
      |>DataRecord.changeset(data_record)
      |>Repo.insert
    end
  end

  def sign do

  end

  def verifySignature do

  end

  def getId do

  end

  def getId2 do

  end

  def getHash do

  end

  def calculateFee do

  end

  defp hash(s) do
    s = :crypto.hash(:sha256, s)
    |> Base.encode64

    [~r/\+/, ~r/ /, ~r/\=/, ~r/\%/, ~r/\//, ~r/\#/, ~r/\$/, ~r/\~/, ~r/\'/, ~r/\@/, ~r/\*/, ~r/\-/]
    |> Enum.reduce(s, fn x, acc -> Regex.replace(x, acc, "") end)
  end

end
