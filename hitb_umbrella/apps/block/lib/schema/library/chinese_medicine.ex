defmodule Block.Library.ChineseMedicine do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Library.ChineseMedicine


  schema "chinese_medicine" do
    field :code, :string #编码
    field :name, :string #名称
    field :name_1, :string #别名
    # add :icd9_aa, {:array, :string}
    field :sexual_taste, :string #性味
    field :toxicity, :string # 毒性
    field :meridian, :string #归经
    field :effect, :string #功效
    field :indication, :string # 适应症
    field :consumption, :string #用量
    field :need_attention, :string #注意事项
    field :type, :string #分类
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end


  def changeset(%ChineseMedicine{} = chinese_medicine, attrs) do
    changeset = chinese_medicine
      |> cast(attrs, [:code, :name, :name_1, :sexual_taste, :toxicity, :meridian, :effect, :indication, :consumption, :need_attention, :type, :previous_hash, :hash, :datetime])
      |> validate_required([:code, :name, :name_1, :sexual_taste, :toxicity, :meridian, :effect, :indication, :consumption, :need_attention, :type, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(chinese_medicine, changeset, "chinese_medicine")
    changeset
  end
end
