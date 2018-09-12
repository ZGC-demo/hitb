defmodule Block.ShareRecord do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.ShareRecord


  schema "share_record" do
    field :file_name,      :string
    field :username,       :string
    field :datetime,       :string
    field :type,           :string
    timestamps()
  end

  @doc false
  def changeset(%ShareRecord{} = share_record, attrs) do
    changeset = share_record
      |> cast(attrs, [:file_name, :username, :datetime, :type])
      |> validate_required([:file_name, :username, :datetime, :type])
    Block.create_data_record(changeset, "share_record")
    changeset
  end
end
