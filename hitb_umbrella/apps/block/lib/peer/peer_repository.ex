defmodule Block.PeerRepository do
  import Ecto.Query, warn: false
  alias Block.Repo
  alias Block.Peer

  def get_peer(host) do
    Repo.get_by(Peer, host: host)
  end

  def insert_peer(peer) do
    IO.inspect %Peer{}|> Peer.changeset(peer)
    %Peer{}
    |> Peer.changeset(peer)
    |> Repo.insert
    :ok
  end

  def update_peer(host, port, attr) do
    peer = Repo.get_by(Peer, host: host, port: port)
    case peer do
      nil -> :error
      _ ->
        peer
        |> Peer.changeset(attr)
        |> Repo.update
        :ok
    end
  end

  def get_all_peers() do
    Repo.all(Peer)
  end

end
