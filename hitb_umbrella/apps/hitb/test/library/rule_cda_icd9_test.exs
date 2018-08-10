defmodule Hitb.Library.RuleCdaIcd9Test do
  use Hitb.DataCase

  alias Hitb.Library.RuleCdaIcd9
  @valid_attrs %{code: "sss", name: "sss", symptoms: ["sss"], breathe: ["ss"], body_heat: ["sss"], sphygums: ["sss"], blood_pressure: ["sss"], examines: ["sss"], create_user: "sss", update_user: "Sss"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RuleCdaIcd9.changeset(%RuleCdaIcd9{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RuleCdaIcd9.changeset(%RuleCdaIcd9{}, @invalid_attrs)
    refute changeset.valid?
  end
end
