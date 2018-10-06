defmodule Block.PeerService do
  require Logger

  alias Block.PeerRepository
  @moduledoc """
  Documentation for Peers.
  """
  def hello do
    :world
  end

  def getPublicIp do
    publicIp = nil
    publicIp
  end

  def getPeers() do
    PeerRepository.get_all_peers()
  end

  def newPeer(host, port)do
    peer = %{host: host, port: port, connect: true}
    hosts = getPeers()|>Enum.map(fn x -> x.host end)
    unless(host in hosts)do
      PeerRepository.insert_peer(peer)
    end
  end

end
