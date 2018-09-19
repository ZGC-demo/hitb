defmodule Block.Library.RuleDrg do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_drg" do
    field :code, :string
    field :name, :string
    field :mdc, :string
    field :adrg, :string
    field :org, :string
    field :year, :string
    field :version, :string
    field :plat, :string
    field :previous_hash, :string
    field :hash, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(rule_drg, params \\ %{}) do
    changeset = rule_drg
      |> cast(params, [:code, :name, :mdc, :adrg, :org, :year, :version, :plat, :previous_hash, :hash])
      |> validate_required([:code, :previous_hash, :hash])
      |> unique_constraint(:hash)
    Block.create_data_record(rule_drg, changeset, "rule_drg")
    changeset
  end

end
