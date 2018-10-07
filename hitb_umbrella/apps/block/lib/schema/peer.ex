defmodule Block.Peer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Peer


  schema "peer" do
    field :host,    :string
    field :port,    :string
    field :connect, :boolean, default: false
    timestamps()
  end

  @doc false
  def changeset(%Peer{} = peer, attrs) do
    changeset = peer
      |> cast(attrs, [:host, :port, :connect])
      |> validate_required([:host, :port, :connect])
      |> unique_constraint(:host)
    # Block.create_data_record(peer, changeset, "peer")
    changeset
  end
end
