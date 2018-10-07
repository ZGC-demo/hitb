defmodule BlockWeb.P2pChannel do
  use Phoenix.Channel
  require Logger

  @latest_block       Block.P2pMessage.latest_block
  @sync_block         Block.P2pMessage.sync_block
  @sync_peer          Block.P2pMessage.sync_peer
  @all_accounts       Block.P2pMessage.all_accounts
  @all_blocks   Block.P2pMessage.all_blocks
  # @update_block_chain Block.P2pMessage.update_block_chain
  # @add_peer_request   Block.P2pMessage.add_peer_request
  @all_transactions "all_transactions"
  @add_block  "add_block"
  alias Block.SyncService
  # @connection_error   Block.P2pMessage.connection_error
  # @connection_success Block.P2pMessage.connection_success
  alias Block.BlockService
  alias Block.PeerService
  alias Block.AccountRepository
  alias Block.BlockRepository
  alias Block.TransactionRepository
  # alias Block.P2pSessionManager
  # alias Block.PeerRepository

  def join("p2p", _payload, socket) do
    {:ok, socket}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def handle_in(@latest_block, %{"ip" => ip}, socket) do
    Enum.each(ip, fn x -> PeerService.newPeer(x["host"], x["port"]) end)
    Logger.info("sending latest block")
    data = BlockService.get_latest_block()|>send()
    {:reply, {:ok, %{type: @latest_block, data: data}}, socket}
  end

  def handle_in(@sync_block, _payload, socket) do
    Logger.info("sync_block")
    data = BlockService.get_latest_block()|>send()
    {:reply, {:ok, %{type: @latest_block, data: data}}, socket}
  end

  def handle_in(@sync_peer, _payload, socket) do
    Logger.info("sync_peer")
    data = PeerService.getPeers()|>Enum.map(fn x -> x.host end)
    {:reply, {:ok, %{type: @sync_peer, data: data}}, socket}
  end

  def handle_in(@all_accounts, _payload, socket) do
    Logger.info("sending all accounts")
    data = AccountRepository.get_all_accounts()|>Enum.map(fn x -> send(x) end)
    {:reply, {:ok, %{type: @all_accounts, data: data}}, socket}
  end

  def handle_in(@all_blocks, _payload, socket) do
    Logger.info("sending all blocks")
    data = BlockRepository.get_all_blocks()|>Enum.map(fn x -> send(x) end)
    {:reply, {:ok, %{type: @all_blocks, data: data}}, socket}
  end

  def handle_in(@all_transactions, _payload, socket) do
    Logger.info("sending all transactions")
    data = TransactionRepository.get_all_transactions()|>Enum.map(fn x -> send(x) end)
    {:reply, {:ok, %{type: @all_transactions, data: data}}, socket}
  end

  def handle_in("other_sync", _payload, socket) do
    data = SyncService.get_data()
    {:reply, {:ok, %{type: "other_sync", data: data}}, socket}
  end

  def handle_in("sync_data", %{"data" => data}, socket) do
    data = Enum.reduce(data, %{}, fn x, acc ->
      attrs = SyncService.get(x)|>Enum.map(fn x -> send(x) end)
      Map.put(acc, x, attrs)
    end)
    {:reply, {:ok, %{type: "sync_data", data: data}}, socket}
  end

  def handle_in(event, payload, socket) do
    Logger.warn("unhandled event #{event} #{inspect payload}")
    {:noreply, socket}
  end

  ####反向同步方法
  def handle_in(@add_block, %{"block" => block}, socket) do
    Enum.each(block, fn x -> BlockService.sync_block(x) end)
    {:reply, {:ok, %{type: "add_accounts"}}, socket}
  end

  def handle_in(@add_accounts, %{"data" => account}, socket) do
    usernames = AccountRepository.get_all_usernames()
    Enum.reject(account, fn x -> x["username"] in usernames end)
    |>Enum.each(fn x -> AccountRepository.insert_account(x) end)
    {:reply, {:ok, %{type: "add_transactions"}}, socket}
  end

  def handle_in("add_transactions", %{"data" => transactions}, socket) do
    transactions_id = TransactionRepository.get_all_transactions_id()
    Enum.reject(transactions, fn x -> x["transaction_id"] in transactions_id end)
    |>Enum.each(fn x -> TransactionRepository.insert_transaction(x) end)
    {:reply, {:ok, %{type: "add_peers"}}, socket}
  end

  def handle_in("add_peers", %{"data" => data}, socket) do
    Enum.each(data, fn x -> Block.PeerService.newPeer(x, "4000") end)
    {:reply, {:ok, %{type: "add_other_sync"}}, socket}
  end

  def handle_in("add_other_sync", %{"data" => data}, socket) do
    local = SyncService.get_data()
    data = Enum.map(local, fn x ->
        {key, local_time} = x
        server_time = Map.get(data, to_string(key))
        cond do
          local_time == server_time -> []
          local_time == "" -> key
          server_time > local_time -> key
          true -> []
        end
      end)|>List.flatten
    case data do
      [] -> {:reply, {:ok, %{type: "over"}}, socket}
      _ -> {:reply, {:ok, %{type: "add_other_data", data: data}}, socket}
    end
  end

  def handle_in("add_other_data", %{"data" => data}, socket) do
    Map.keys(data)
    |>Enum.map(fn key ->
        local = SyncService.get_hashs(key)
        Map.get(data, key)
        |>Enum.reject(fn x -> x["hash"] in local end)
        |>Enum.each(fn x ->
            SyncService.insert(key, x)
        end)
    end)
    {:reply, {:ok, %{type: "over"}}, socket}
  end
  ####反向同步方法

  defp send(map) do
    Map.drop(map, [:id, :__meta__, :__struct__])
  end
end
