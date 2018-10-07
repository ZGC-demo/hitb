defmodule Block.Stat.StatFile do
  use Ecto.Schema
  import Ecto.Changeset


  schema "stat_file" do
    field :first_menu, :string
    field :second_menu, :string
    field :file_name, :string
    field :page_type, :string
    field :hash, :string
    field :datetime, :string
    # field :insert_user, :string
    # field :update_user, :string
    # field :header, :string
    timestamps()
  end

  def changeset(stat_file, params \\ %{}) do
    changeset = stat_file
      |> cast(params, [:first_menu, :second_menu, :file_name, :page_type, :hash, :datetime])
      |> validate_required([:first_menu, :second_menu, :file_name, :page_type, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(stat_file, changeset, "stat_file")
    changeset
  end
end
