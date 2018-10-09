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

  # can't inherit attributes and use them inside mat
  @all_accounts       Block.P2pMessage.all_accounts
  @latest_block       Block.P2pMessage.latest_block
  @all_blocks         Block.P2pMessage.all_blocks
  @all_transactions   Block.P2pMessage.all_transactions
  @connection_error   Block.P2pMessage.connection_error
  @connection_success Block.P2pMessage.connection_success
  @other_sync         Block.P2pMessage.other_sync
  @sync_data          Block.P2pMessage.sync_data
  @sync_peer          Block.P2pMessage.sync_peer

  @add_block          Block.P2pMessage.add_block
  @add_accounts       Block.P2pMessage.add_accounts
  @add_transactions   Block.P2pMessage.add_transactions
  @add_peers          Block.P2pMessage.add_peers
  @add_other_sync     Block.P2pMessage.add_other_sync
  @add_other_data     Block.P2pMessage.add_other_data

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
    {:ok, state}
  end

  def handle_joined(topic, _payload, transport, state) do
    Logger.info("joined the topic #{topic}.")
    GenSocketClient.push(transport, "p2p", @sync_peer, %{})
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

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @sync_peer, "data" => data}}, transport, state) do
    Enum.each(data, fn x -> Block.PeerService.newPeer(x, "4000") end)
    ip =
      case :ets.lookup(:local_ip, :local_ip) do
        [] -> []
        local_ip -> local_ip|>List.last|>elem(1)
      end
    GenSocketClient.push(transport, "p2p", @latest_block, %{ip: ip})
    {:ok, state}
  end

  def handle_reply("p2p", _ref, %{"response" => %{"type" => @latest_block, "data" => data}}, transport, state) do
    latest_block = BlockService.get_latest_block()
    cond do
      latest_block == nil ->
        GenSocketClient.push(transport, "p2p", @all_blocks, %{})
      latest_block.index > data["index"] ->
        block = BlockService.get_blocks()
        GenSocketClient.push(transport, "p2p", @add_block, %{block: block})
      latest_block.index < data["index"] ->
        GenSocketClient.push(transport, "p2p", @all_blocks, %{})
      latest_block.index == data["index"] ->
        :timer.send_interval(10000, :ping)
    end
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @all_blocks, "data" => block}}, transport, state) do
    # #取得区块
    hashs = BlockService.get_all_block_hashs()
    #同步
    Enum.reject(block, fn x -> x["hash"] in hashs end)
    |>Enum.map(fn x ->
        Enum.reduce(Map.keys(x), %{}, fn k, acc ->
          Map.put(acc, String.to_atom(k), Map.get(x, k))
        end)
      end)
    |>Enum.each(fn x -> BlockService.sync_block(x) end)
    #下一个同步
    GenSocketClient.push(transport, "p2p", @all_accounts, %{})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @all_accounts, "data" => account}}, transport, state) do
    #取得全部用户名
    usernames = AccountRepository.get_all_usernames()
    #同步
    Enum.reject(account, fn x -> x["username"] in usernames end)
    |>Enum.each(fn x -> AccountRepository.insert_account(x) end)
    #下一个同步
    GenSocketClient.push(transport, "p2p", @all_transactions, %{})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @all_transactions, "data" => transactions}}, transport, state) do
    transactions_id = TransactionRepository.get_all_transactions_id()
    #同步
    Enum.reject(transactions, fn x -> x["transaction_id"] in transactions_id end)
    |>Enum.each(fn x -> TransactionRepository.insert_transaction(x) end)
    GenSocketClient.push(transport, "p2p", @other_sync, %{})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @other_sync, "data" => data}}, transport, state) do
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
      [] -> :timer.send_interval(10000, :ping)
      _ -> GenSocketClient.push(transport, "p2p", @sync_data, %{data: data})
    end
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @sync_data, "data" => data}}, _transport, state) do
    Map.keys(data)
    |>Enum.map(fn key ->
        local = SyncService.get_hashs(key)
        Map.get(data, key)
        |>Enum.reject(fn x -> x["hash"] in local end)
        |>Enum.each(fn x ->
            SyncService.insert(key, x)
        end)
    end)
    Logger.info("sync finish.")
    :timer.send_interval(10000, :ping)
    {:ok, state}
  end

  ##向服务器反向同步
  def handle_reply(_topic, _ref, %{"response" => %{"type" => @add_accounts}}, transport, state) do
    #取得全部用户名
    Logger.info("sending all accounts")
    data = AccountRepository.get_all_accounts()|>Enum.map(fn x -> send(x) end)
    # #下一个同步
    GenSocketClient.push(transport, "p2p", @add_accounts, %{data: data})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @add_transactions}}, transport, state) do
    Logger.info("sending all transactions")
    data = TransactionRepository.get_all_transactions()|>Enum.map(fn x -> send(x) end)
    # #下一个同步
    GenSocketClient.push(transport, "p2p", @add_transactions, %{data: data})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @add_peers}}, transport, state) do
    Logger.info("sync_peer")
    data = PeerService.getPeers()|>Enum.map(fn x -> x.host end)
    GenSocketClient.push(transport, "p2p", @add_peers, %{data: data})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @add_other_sync}}, transport, state) do
    data = SyncService.get_data()
    GenSocketClient.push(transport, "p2p", @add_other_sync, %{data: data})
    {:ok, state}
  end

  def handle_reply(_topic, _ref, %{"response" => %{"type" => @add_other_data, "data" => data}}, transport, state) do
    data = Enum.reduce(data, %{}, fn x, acc ->
      attrs = SyncService.get(x)|>Enum.map(fn x -> send(x) end)
      Map.put(acc, x, attrs)
    end)
    GenSocketClient.push(transport, "p2p", @add_other_data, %{data: data})
    {:ok, state}
  end

  ##向服务器反向同步

  def handle_reply(_topic, _ref, _payload, transport, state) do
    GenSocketClient.push(transport, "p2p", @all_accounts, %{})
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting")
    {:connect, state}
  end

  def handle_info(:ping, transport, state) do
    # Logger.info("sync_block")
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

  defp send(map) do
    Map.drop(map, [:id, :__meta__, :__struct__])
  end

end
