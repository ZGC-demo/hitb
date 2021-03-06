defmodule Block.Library.LibWt4 do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Library.LibWt4


  schema "lib_wt4" do
    field :code, :string #编码
    field :name, :string #名称
    field :year, :string #年份
    field :type, :string #类型
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end

  @doc false
  def changeset(%LibWt4{} = lib_wt4, attrs) do
    changeset = lib_wt4
      |> cast(attrs, [:code, :name, :year, :type, :previous_hash, :hash, :datetime])
      |> validate_required([:code, :name, :type, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(lib_wt4, changeset, "lib_wt4")
    changeset
  end
end
