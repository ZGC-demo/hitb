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
  alias Block.BlockRepository
  alias Block.PeerService
  alias Phoenix.Channels.GenSocketClient
  alias Block.SyncService
  alias Block.P2pSessionManager
  alias Block.TransactionRepository
  alias Block.Stat.StatOrg
  alias Block.Stat.StatCda
  alias Block.Edit.Cda
  alias Block.Edit.CdaFile
  alias Block.Library.Cdh
  alias Block.Library.ChineseMedicinePatent
  alias Block.Library.ChineseMedicine
  alias Block.Library.RuleMdc
  alias Block.Library.RuleAdrg
  alias Block.Library.RuleDrg
  alias Block.Library.RuleIcd9
  alias Block.Library.RuleIcd10
  alias Block.Library.LibWt4
  alias Block.Library.Wt4
  alias Block.Library.RuleCdaIcd10
  alias Block.Library.RuleCdaIcd9
  alias Block.Library.RuleExamine
  alias Block.Library.RulePharmacy
  alias Block.Library.RuleSign
  alias Block.Library.RuleSymptom
  alias Block.Repo



  @behaviour GenSocketClient

  # can't inherit attributes and use them inside matches, so this is necessary
  @sync_peer     Block.P2pMessage.sync_peer
  @sync_block     Block.P2pMessage.sync_block
  @query_all_accounts   Block.P2pMessage.query_all_accounts
  @query_latest_block     Block.P2pMessage.query_latest_block
  @query_all_blocks       Block.P2pMessage.query_all_blocks
  @query_all_transactions   Block.P2pMessage.query_all_transactions
  # @update_block_chain Peers.P2pMessage.update_block_chain
  @add_peer_request   Block.P2pMessage.add_peer_request
  @connection_error   Block.P2pMessage.connection_error
  @connection_success Block.P2pMessage.connection_success

  def start_link(host, port, local_ip) do
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
    %{url: url, host: host} = state
    Logger.error("disconnected:  #{url}  connect error. 20 minutes later attempting to reconnect...")
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
    hosts = PeerService.getPeers()|>Enum.map(fn x -> %{host: x.host, port: x.port} end)
    ip = (hosts ++ ip)|>:lists.usort
    GenSocketClient.push(transport, "p2p", @query_latest_block, %{ip: ip})
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

  def handle_reply("p2p", _ref, %{"response" => %{"type" => @connection_error}} = _payload, _transport, state) do
    Logger.info("connection to server failed...")
    P2pSessionManager.terminate_session(self())
    {:ok, state}
  end

  def handle_reply(_topic, _ref, payload, transport, state) do
    type = payload["response"]["type"]
    response = payload["response"]["data"]
    # @query_all_accounts
    case type do
      "sync_block" ->
        if(Map.get(response, "hash") != Map.get(BlockService.get_latest_block, :hash))do
          GenSocketClient.push(transport, "p2p", @query_all_blocks, %{})
        end
      "sync_peer" ->
        hosts = PeerService.getPeers()|>Enum.map(fn x -> x.host end)
        ip =
          case :ets.lookup(:local_ip, :local_ip) do
            [] -> []
            local_ip -> local_ip|>List.last|>elem(1)
          end
          |>Enum.map(fn x -> x.host end)
        hosts = (ip ++ hosts)|>:lists.usort
        Enum.reject(response, fn x -> x in hosts end)
        |>Enum.map(fn x -> PeerService.newPeer(x, "4000") end)
        PeerService.getPeers()
        |>Enum.map(fn x -> P2pSessionManager.connect(x.host, x.port, []) end)
      "get_latest_block" ->
        if(BlockService.get_latest_block == nil or Map.get(response, "hash") != Map.get(BlockService.get_latest_block, :hash))do
          GenSocketClient.push(transport, "p2p", @query_all_blocks, %{})
        else
          GenSocketClient.push(transport, "p2p", @sync_peer, %{})
        end
      "get_all_blocks" ->
        res_hash = response|>Enum.map(fn x -> x["hash"] end)
        hash = BlockRepository.get_all_blocks()|>Enum.map(fn x -> x.hash end)
        response = Enum.reject(response, fn x -> x["hash"] in hash end)
        if(response === [])do
          Enum.map(response, fn x -> BlockRepository.insert_block(x) end)
        else
          GenSocketClient.push(transport, "p2p", @query_all_transactions, %{})
        end
      "get_all_blocks" ->
        block_hashs = BlockRepository.get_all_block_hashs
        blocks = response
        |> Enum.reject(fn x -> x["hash"] in block_hashs end)
        #区块不全后同步其他部分
        if(blocks != [] and blocks != nil)do
          blocks|> Enum.each(fn x -> BlockRepository.insert_block(x) end)
          GenSocketClient.push(transport, "p2p", @query_all_transactions, %{})
        end
      "get_all_accounts" ->
        usernames = AccountRepository.get_all_usernames()
        response
        |> Enum.reject(fn x -> x["username"] in usernames end)
        |> Enum.each(fn x -> AccountRepository.insert_account(x) end)
        GenSocketClient.push(transport, "p2p", @query_latest_block, %{})
      "query_all_transactions" ->
        transactios_id = TransactionRepository.get_all_transactions_id()
        response
        |> Enum.reject(fn x -> x["transaction_id"] in transactios_id end)
        |> Enum.each(fn x -> TransactionRepository.insert_transaction(x) end)
        GenSocketClient.push(transport, "p2p", "other_sync",
          %{
            statorg_hash: SyncService.get_statorg_hash(),
            statcda_hash: SyncService.get_stat_cda_hash(),
            cda_hash: SyncService.get_cda_hash(),
            cda_file_hash: SyncService.get_cda_file_hash(),
            cdh_hash: SyncService.get_cah_hash(),
            ruleadrg_hash: SyncService.get_ruleadrg_hash(),
            cmp_hash: SyncService.get_cmp_hash(),
            cm_hash: SyncService.get_cm_hash(),
            ruledrg_hash: SyncService.get_ruledrg_hash(),
            ruleicd9_hash: SyncService.get_ruleicd9_hash(),
            ruleicd10_hash: SyncService.get_ruleicd10_hash(),
            rulemdc_hash: SyncService.get_rulemdc_hash(),
            libwt4_hash: SyncService.get_libwt4_hash(),
            wt4_hash: SyncService.get_wt4_hash(),
            rulecdaicd10_hash: SyncService.get_rule_cda_icd10_hash(),
            rulecdaicd9_hash: SyncService.get_rule_cda_icd9_hash(),
            ruleexamine_hash: SyncService.get_rule_examine_hash(),
            rulepharmacy_hash: SyncService.get_rule_pharmacy_hash(),
            rulesign_hash: SyncService.get_rule_sign_hash(),
            rulesymptom_hash: SyncService.get_rule_symptom_hash()})
      "other_sync" ->
        Map.keys(response)
        |>Enum.each(fn k ->
            Enum.each(Map.get(response, k), fn x ->
              case k do
                "statorg_hash" ->
                  %StatOrg{}
                  |>StatOrg.changeset(x)
                "statcda_hash" ->
                  %StatCda{}
                  |>StatCda.changeset(x)
                "cda_hash" ->
                  %Cda{}
                  |>Cda.changeset(x)
                "cda_file_hash" ->
                  %CdaFile{}
                  |>CdaFile.changeset(x)
                "cdh_hash" ->
                  %Cdh{}
                  |>Cdh.changeset(x)
                "ruleadrg_hash" ->
                  %RuleAdrg{}
                  |>RuleAdrg.changeset(x)
                "cmp_hash" ->
                  %ChineseMedicinePatent{}
                  |>ChineseMedicinePatent.changeset(x)
                "cm_hash" ->
                  %ChineseMedicine{}
                  |>ChineseMedicine.changeset(x)
                "ruledrg_hash" ->
                  %RuleDrg{}
                  |>RuleDrg.changeset(x)
                "ruleicd9_hash" ->
                  %RuleIcd9{}
                  |>RuleIcd9.changeset(x)
                "ruleicd10_hash" ->
                  %RuleIcd10{}
                  |>RuleIcd10.changeset(x)
                "rulemdc_hash" ->
                  %RuleMdc{}
                  |>RuleMdc.changeset(x)
                "libwt4_hash" ->
                  %LibWt4{}
                  |>LibWt4.changeset(x)
                "wt4_hash" ->
                  %Wt4{}
                  |>Wt4.changeset(x)
                "rulecdaicd10_hash" ->
                  %RuleCdaIcd10{}
                  |>RuleCdaIcd10.changeset(x)
                "rulecdaicd9_hash" ->
                  %RuleCdaIcd9{}
                  |>RuleCdaIcd9.changeset(x)
                "ruleexamine_hash" ->
                  %RuleExamine{}
                  |>RuleExamine.changeset(x)
                "rulepharmacy_hash" ->
                  %RulePharmacy{}
                  |>RulePharmacy.changeset(x)
                "rulesign_hash" ->
                  %RuleSign{}
                  |>RuleSign.changeset(x)
                "rulesymptom_hash" ->
                  %RuleSymptom{}
                  |>RuleSymptom.changeset(x)
              end
              |>Repo.insert
            end)
        end)
        :timer.send_interval(10000, :ping)
    end
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting")
    {:connect, state}
  end

  def handle_info(:ping, transport, state) do
    GenSocketClient.push(transport, "p2p", @query_latest_block, %{})
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

  # def handle_info(@query_latest_block, transport, state) do
  #   Logger.info("quering for latest blocks")
  #   GenSocketClient.push(transport, "p2p", @query_latest_block, %{})
  #   {:ok, state}
  # end

  # def handle_info(@add_peer_request, transport, state) do
  #   Logger.info("sending request to add me as a peer")
  #   local_server_host = Application.get_env(:oniichain, BlockWeb.Endpoint)[:url][:host]
  #   local_server_port = Application.get_env(:oniichain, BlockWeb.Endpoint)[:http][:port]
  #   GenSocketClient.push(transport, "p2p", @add_peer_request, %{host: local_server_host, port: local_server_port})
  #   {:ok, state}
  # end

  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled message #{inspect message}")
    {:ok, state}
  end

  def handle_call(_message, _arg1, _transport, _callback_state) do
    reply = :reply
    new_state = :new_state
    {:reply, reply, new_state}
  end

  # case :ets.lookup(:client, :transport) do
  #   [] -> :ets.insert(:client, {:transport, [transport]})
  #   transports ->
  #     IO.inspect transport
  #     IO.inspect transports
  #     :ets.insert(:client, {:transport, [transport] ++ transports |> hd |> elem(1)})
  # end
end
