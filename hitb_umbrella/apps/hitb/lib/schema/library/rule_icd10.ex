defmodule Hitb.Library.RuleIcd10 do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rule_icd10" do
    field :code, :string
    field :name, :string
    field :codes, {:array, :string}
    field :icdcc, :string
    field :dissect, :string
    field :icdc, :string
    field :icdc_az, :string
    field :adrg, {:array, :string}
    field :mdc, {:array, :string}
    field :cc, :boolean, default: false
    field :nocc_1, {:array, :string}
    field :nocc_a, {:array, :string}
    field :nocc_aa, {:array, :string}
    field :mcc, :boolean, default: false
    field :org, :string
    field :year, :string
    field :version, :string
    field :plat, :string
    field :create_user, :string
    field :update_user, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:code, :name, :codes, :dissect, :icdcc, :icdc, :icdc_az, :adrg, :cc, :nocc_1, :nocc_a, :nocc_aa, :mcc, :org, :year, :version, :plat, :mdc, :create_user, :update_user])
    |> validate_required([:code, :create_user, :update_user])
  end

end
