defmodule Block.P2pClientHandler do
  @moduledoc """
  Receives and handles messages over websocket.
  Responsible for keeping the block chain in sync.
  """
  require Logger
  # import Ecto.Query
  # alias Block.PeerRepository
  alias Block.AccountRepository
  alias Block.BlockService
  alias Block.PeerService
  alias Phoenix.Channels.GenSocketClient
  alias Block.SyncService
  alias Block.P2pSessionManager
  alias Block.TransactionRepository



  @behaviour GenSocketClient

  # can't inherit attributes and use them inside matches, so this is necessary
  # @sync_peer     Block.P2pMessage.sync_peer
  # @sync_block     Block.P2pMessage.sync_block
  @all_accounts   Block.P2pMessage.all_accounts
  @latest_block     Block.P2pMessage.latest_block
  @all_blocks       Block.P2pMessage.all_blocks
  @all_transactions   Block.P2pMessage.all_transactions
  # @update_block_chain Peers.P2pMessage.update_block_chain
  # @add_peer_request   Block.P2pMessage.add_peer_request
  @connection_error   Block.P2pMessage.connection_error
  @connection_success Block.P2pMessage.connection_success
  @add_block         "add_block"

  def start_link(host, port, _ip) do
    GenSocketClient.start_link(
          __MODULE__,
          Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
          "ws://#{host}:#{port}/p2p/websocket"
        )
  end

  def init(url) do
    host = Regex.replace(~r/ws:\/\//, url, "")
    host = Regex.replace(~r/:4000\/p2p\/websocket/, host, "")
    {:connect, url, [], %{host: host, url: url}}
  end

  def join(_transport, _topic, _payload \\ %{}) do

  end

  def handle_connected(transport, state) do
    %{url: url} = state
    Logger.info("#{url}  connected")
    GenSocketClient.join(transport, "p2p")
    {:ok, state}
  end

  def handle_disconnected(_reason, state) do
    %{host: host} = state
    Logger.error("disconnected: #{host} connect error. 20 minutes later attempting to reconnect...")
    # PeerService.getPeers()
    # |>Enum.reject(fn x -> x.host == host end)
    # |>Enum.map(fn x -> P2pSessionManager.connect(x.host, x.port, []) end)
    {:ok, state}
  end

  def handle_joined(topic, _payload, transport, state) do
    Logger.info("joined the topic #{topic}.")
    ip =
      case :ets.lookup(:local_ip, :local_ip) do
        [] -> []
        local_ip -> local_ip|>List.last|>elem(1)
      end
    GenSocketClient.push(transport, "p2p", @latest_block, %{ip: ip})
    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    Logger.error("join error on the topic #{topic}: #{inspect payload}")
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    Logger.error("disconnected from the topic #{topic}: #{inspect payload}. Attempting to rejoin...")
    Process.send_after(self(), {:join, topic}, :timer.seconds(20000))
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    Logger.info("message on topic #{topic}: #{event} #{inspect payload}")
    {:ok, state}
  end

  def handle_reply("p2p", _ref, %{"response" => %{"type" => @connection_success}} = payload, _transport, state) do
    Logger.info("server ack ##{inspect payload["response"]}")
    {:ok, state}
  end

  def handle_reply("p2p", _ref, %{"response" => %{"type" => @connection_error}}, _transport, state) do
    Logger.info("connection to server failed...")
    P2pSessionManager.terminate_session(self())
    {:ok, state}
  end

  # def handle_reply("p2p", _ref, %{"response" => %{"type" => @latest_block, "data" => data}}, transport, state) do
  def handle_reply("p2p", _ref, %{"response" => %{"type" => @latest_block, "data" => data}}, transport, state) do
    cond do
      BlockService.get_latest_block() == nil ->
        GenSocketClient.push(transport, "p2p", @all_blocks, %{})
      BlockService.get_latest_block().index > data["index"] ->
        block = BlockService.get_blocks()
        GenSocketClient.push(transport, "p2p", @add_block, %{block: block})
      BlockService.get_latest_block().index < data["index"] ->
        GenSocketClient.push(transport, "p2p", @all_blocks, %{})
      BlockService.get_latest_block().index == data["index"] ->
        GenSocketClient.push(transport, "p2p", @all_blocks, %{})
    end
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @all_accounts, "data" => account}}, transport, state) do
    Enum.each(account, fn x -> AccountRepository.insert_account(x) end)
    GenSocketClient.push(transport, "p2p", @all_transactions, %{})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @all_transactions, "data" => transactions}}, transport, state) do
    Enum.each(transactions, fn x -> TransactionRepository.insert_transaction(x) end)
    GenSocketClient.push(transport, "p2p", "other_sync", %{})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => "other_sync", "data" => data}}, transport, state) do
    local = SyncService.get_data()
    data = Map.keys(data)
      |>Enum.map(fn x ->
        case Map.get(data, x) do
          [] -> []
          v ->
            v2 = Map.get(local, String.to_atom(x))
            if(List.first(v) > List.first(v2))do x else [] end
        end
      end)
      |>List.flatten
    GenSocketClient.push(transport, "p2p", "other_sync2", %{data: data})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => "other_sync2", "data" => data}}, transport, state) do
    Map.keys(data)
    |>Enum.map(fn key ->
        Map.get(data, key)
        |>Enum.each(fn x ->
            SyncService.insert(key, x)
        end)
    end)
    GenSocketClient.push(transport, "p2p", "sync_peer", %{data: data})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => "sync_peer", "data" => data}}, _transport, state) do
    Enum.each(data, fn x -> Block.PeerService.newPeer(x, "4000") end)
    PeerService.getPeers()
    |>Enum.each(fn x -> Block.P2pSessionManager.connect(x.host, x.port, []) end)
    Logger.warn("Sync over.")
    :timer.send_interval(10000, :ping)
    {:ok, state}
  end

  def handle_reply(_topic, _ref, _payload, transport, state) do
    GenSocketClient.push(transport, "p2p", @all_accounts, %{})
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting")
    {:connect, state}
  end

  def handle_info(:ping, transport, state) do
    GenSocketClient.push(transport, "p2p", @latest_block, %{ip: []})
    {:ok, state}
  end

  def handle_info({:join, topic}, transport, state) do
    Logger.info("joining the topic #{topic}")
    case GenSocketClient.join(transport, topic) do
      {:error, reason} ->
        Logger.error("error joining the topic #{topic}: #{inspect reason}. Attempting to rejoin...")
        Process.send_after(self(), {:join, topic}, :timer.seconds(1))
      {:ok, _ref} -> :ok
    end

    {:ok, state}
  end
  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled message #{inspect message}")
    {:ok, state}
  end

  def handle_call(_message, _arg1, _transport, _callback_state) do
    reply = :reply
    new_state = :new_state
    {:reply, reply, new_state}
  end

end
