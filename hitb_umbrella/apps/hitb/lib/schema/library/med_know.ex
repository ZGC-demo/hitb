defmodule Hitb.Library.MdeKnow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hitb.Library.MdeKnow

  schema "mde_know" do
    field :name, :string
    field :en_name, :string
    field :desc, :string
    field :keywords, {:array, :string}
    field :create_user, :string
    field :update_user, :string
    timestamps()
  end

  def changeset(%MdeKnow{} = mde_know, attrs) do
    mde_know
    |> cast(attrs, [:name, :en_name, :desc, :keywords, :create_user, :update_user])
    |> validate_required([:name, :create_user, :desc, :update_user])
  end
end
