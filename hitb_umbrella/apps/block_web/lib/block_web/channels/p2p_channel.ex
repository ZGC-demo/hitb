defmodule BlockWeb.P2pChannel do
  use Phoenix.Channel
  require Logger

  @latest_block       Block.P2pMessage.latest_block
  @sync_block         Block.P2pMessage.sync_block
  @sync_peer          Block.P2pMessage.sync_peer
  @all_accounts       Block.P2pMessage.all_accounts
  @all_blocks   Block.P2pMessage.all_blocks
  # @update_block_chain Block.P2pMessage.update_block_chain
  @add_peer_request   Block.P2pMessage.add_peer_request
  @all_transactions "all_transactions"
  @add_block  "add_block"
  alias Block.SyncService
  @connection_error   Block.P2pMessage.connection_error
  @connection_success Block.P2pMessage.connection_success
  alias Block.BlockService
  alias Block.PeerService
  alias Block.AccountRepository
  alias Block.BlockRepository
  alias Block.TransactionRepository
  alias Block.P2pSessionManager
  # alias Block.PeerRepository

  def join("p2p", _payload, socket) do
    {:ok, socket}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def handle_in(@latest_block, %{"ip" => ip}, socket) do
    hosts = PeerService.getPeers()|>Enum.map(fn x -> x.host end)
    new_hosts = ip|>Enum.map(fn x -> x["host"] end)
    Enum.reject(ip, fn x -> x["host"] in hosts end)
    |>Enum.each(fn x -> PeerService.newPeer(x["host"], x["port"]) end)
    Logger.info("sending latest block")
    data = BlockService.get_latest_block()|>send()
    {:reply, {:ok, %{type: @latest_block, data: data}}, socket}
  end

  def handle_in(@add_block, %{"block" => block}, socket) do
    Enum.each(block, fn x -> BlockRepository.insert_block(x) end)
    {:reply, {:ok, %{type: "add_transactions", block: block}}, socket}
  end

  def handle_in(@sync_block, _payload, socket) do
    Logger.info("sync_block")
    data = BlockService.get_latest_block()|>send()
    {:reply, {:ok, %{type: @latest_block, data: data}}, socket}
  end

  def handle_in(@sync_peer, _payload, socket) do
    Logger.info("sync_peer")
    data = PeerService.getPeers()|>Enum.map(fn x -> x.host end)
    IO.inspect data
    {:reply, {:ok, %{type: @sync_peer, data: data}}, socket}
  end

  def handle_in(@query_all_accounts, _payload, socket) do
    Logger.info("sending all accounts")
    data = AccountRepository.get_all_accounts()|>Enum.map(fn x -> send(x) end)
    {:reply, {:ok, %{type: @query_all_accounts, data: data}}, socket}
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

  def handle_in("other_sync", payload, socket) do
    data =
      Map.keys(payload)
      |>Enum.reduce(%{}, fn x, acc ->
          data = SyncService.get_data(x, Map.get(payload, x))
          Map.put(acc, String.to_atom(x), data)
        end)
    {:reply, {:ok, %{type: "other_sync", data: data}}, socket}
  end

  # def handle_in("acto_sync", payload, socket) do
  #   PeerRepository.get_all_peers
  #   |> Enum.each(fn x -> Block.P2pSessionManager.connect(x.host, x.port) end)
  #   {:reply, {:ok, %{type: "acto_sync", data: []}}, socket}
  # end

  def handle_in(event, payload, socket) do
    Logger.warn("unhandled event #{event} #{inspect payload}")
    {:noreply, socket}
  end

  defp send(map) do
    Map.drop(map, [:id, :__meta__, :__struct__])
  end
end
