defmodule Hitb.Library.LibWt4 do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hitb.Library.LibWt4


  schema "lib_wt4" do
    field :code, :string #编码
    field :name, :string #名称
    field :year, :string #年份
    field :type, :string #类型
    field :create_user, :string
    field :update_user, :string
    timestamps()
  end

  @doc false
  def changeset(%LibWt4{} = lib_wt4, attrs) do
    lib_wt4
    |> cast(attrs, [:code, :name, :year, :type, :create_user, :update_user])
    |> validate_required([:code, :name, :type, :create_user, :update_user])
  end
end
