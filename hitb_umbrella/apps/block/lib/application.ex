defmodule Block.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      Block.S1,
      Block.S2,
      supervisor(Block.Repo, [])
    ]
    opts = [strategy: :one_for_one, name: Block.Supervisor]
    supervisor = Supervisor.start_link(children, opts)
    initialize_datastore()
    supervisor
  end

  def initialize_datastore() do
    :ets.new(:local_ip, [:set, :public, :named_table])
    :ets.new(:peers, [:set, :public, :named_table])
    :ets.new(:latest_block, [:set, :public, :named_table])
    :ets.new(:client, [:set, :public, :named_table])
    init_peer()
    # generate_initial_block()
  end

  defp init_peer() do
    database = Block.Repo.config()|>Enum.reject(fn x -> elem(x, 0) != :database end)|>List.first|>elem(1)
    init_peer = %{
      host:  "192.168.0.60",
      port:  "4000",
      connect: true
    }
    local_ip = :inet.getifaddrs()
      |>elem(1)
      |>Enum.map(fn x -> {to_string(elem(x, 0)), elem(x, 1)} end)
      |>Enum.reject(fn x -> elem(x, 0) == "lo" end)
      |>Enum.reject(fn x -> String.contains?(elem(x, 0), "docker") end)
      |>Enum.map(fn x -> List.keyfind(elem(x, 1), :addr, 0) end)
      |>Enum.reject(fn x -> x == nil end)
      |>Enum.map(fn x -> %{host: elem(x, 1)|>Tuple.to_list|>Enum.join("."), port: "4000"} end)
    # IO.inspect local_ip
      # |>Enum.map(fn x -> elem(x, 1)|>Tuple.to_list|>Enum.join(":") end)
    if(database != "block_test")do
      Block.P2pSessionManager.connect(init_peer.host, init_peer.port, local_ip)
    end
    # peers = Block.PeerRepository.get_all_peers
    # if(peers != [])do
    #   peers |> Enum.each(fn x -> Block.P2pSessionManager.connect(x.host, x.port) end)
    # else
    #   case Block.P2pSessionManager.connect(init_peer.host, init_peer.port) do
    #     :ok ->
    #       Block.PeerRepository.insert_peer(init_peer)
    #     _ ->
    #       Block.PeerRepository.insert_peer(%{init_peer | :connect => false})
    #   end
    # end
  end


  # defp generate_initial_block() do
  #   if(Block.BlockRepository.get_all_blocks == [])do
  #     secret = "someone manual strong movie roof episode eight spatial brown soldier soup motor"
  #     init_block = %{
  #       index: 0,
  #       previous_hash: "0",
  #       timestamp: :os.system_time(:seconds),
  #       data: "foofizzbazz",
  #       hash: :crypto.hash(:sha256, "cool") |> Base.encode64 |> regex,
  #       generateAdress: :crypto.hash(:sha256, "#{secret}")|> Base.encode64 |> regex
  #     }
  #     Block.BlockRepository.insert_block(init_block)
  #     if(Block.AccountRepository.get_all_accounts == [])do
  #       Block.AccountService.newAccount(%{username: secret, balance: 100000000})
  #     end
  #     init_transaction = %{
  #       transaction_id: Block.TransactionService.generateId,
  #       height: init_block.index,
  #       blockId: to_string(init_block.index),
  #       type:                 3,
  #       timestamp:            init_block.timestamp,
  #       datetime:             Block.TransactionService.generateDateTime,
  #       senderPublicKey:      :crypto.hash(:sha256, "publicKey#{secret}")|> Base.encode64|> regex,
  #       requesterPublicKey:   "",
  #       senderId:             "",
  #       recipientId:          "SYSTEM",
  #       amount:               0,
  #       fee:                  0,
  #       signature:            "",
  #       signSignature:       "",
  #       asset:                [],
  #       args:                 [],
  #       message:              "创世区块"
  #     }
  #     Block.TransactionRepository.insert_transaction(init_transaction)
  #   end
  # end
  #
  # defp regex(s) do
  #   [~r/\+/, ~r/ /, ~r/\=/, ~r/\%/, ~r/\//, ~r/\#/, ~r/\$/, ~r/\~/, ~r/\'/, ~r/\@/, ~r/\*/, ~r/\-/]
  #   |> Enum.reduce(s, fn x, acc -> Regex.replace(x, acc, "") end)
  # end
end
