defmodule Block.BlockRepository do
  import Ecto.Query, warn: false
  alias Block.Repo
  alias Block.BlockList

  def insert_block(block, type \\ "insert") do
    %BlockList{}
    |> BlockList.changeset(block, type)
    |> Repo.insert
    :ets.insert(:latest_block, {:latest, block})
    :ok
  end

  def get_block(index) do
    Repo.get_by(BlockList, index: String.to_integer(index))
  end

  def get_block_by_hash(hash) do
    Repo.get_by(BlockList, hash: hash)
  end

  def get_all_blocks() do
    Repo.all(from p in BlockList, order_by: [asc: p.index])
  end

  def replace_chain(block_chain, latest_block) do
    Enum.each(block_chain, fn block ->
      insert_block(block)
    end)
    :ets.insert(:latest_block, {:latest, latest_block})
  end

  def get_latest_block() do
    index = Repo.all(from p in BlockList, select: count(p.id))|>List.first
    block = Repo.get_by(BlockList, index: index - 1)
    :ets.insert(:latest_block, {:latest, block})
    block
  end

  def del_all_block() do
    Repo.delete_all(BlockList)
  end
end
