defmodule Hitb.Library.Cdh do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hitb.Library.Cdh


  schema "cdh" do
    field :key, :string
    field :value, :string
    field :username, :string
    field :create_user, :string
    field :update_user, :string
    timestamps()
  end

  @doc false
  def changeset(%Cdh{} = cdh, attrs) do
    cdh
    |> cast(attrs, [:key, :value, :username, :create_user, :update_user])
    |> validate_required([:key, :create_user, :update_user])
  end
end
