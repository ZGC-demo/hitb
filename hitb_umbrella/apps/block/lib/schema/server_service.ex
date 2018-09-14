defmodule Block.ServerService do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.ServerService


  schema "server_service" do
    field :host,    :string
    field :port,    :string
    field :info,    :string
    field :version, :string
    field :connect, :boolean, default: false
    timestamps()
  end

  @doc false
  def changeset(%ServerService{} = server_service, attrs) do
    server_service
    |> cast(attrs, [:host, :port, :connect, :info, :version])
    |> validate_required([:host, :port, :connect, :info, :version])
  end
end
