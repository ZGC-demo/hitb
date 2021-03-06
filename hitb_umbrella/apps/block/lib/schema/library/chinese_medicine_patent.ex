defmodule Block.Library.ChineseMedicinePatent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Block.Library.ChineseMedicinePatent


  schema "chinese_medicine_patent" do
    field :code, :string #药品分类代码
    field :medicine_type, :string #药品类型
    field :type, :string #药品分类
    field :medicine_code, :string #药品名称
    field :name, :string #名称
    field :name_1, :string #其他名称
    field :other_spec, :string #其他规格
    field :org_limit, :string#限门诊或住院使用
    field :department_limit, :string#限医疗机构等级
    field :user_limit, :string#人员限制
    field :other_limit, :string#其他限制
    field :previous_hash, :string
    field :hash, :string
    field :datetime, :string
    timestamps()
  end


  def changeset(%ChineseMedicinePatent{} = chinese_medicine_patent, attrs) do
    changeset = chinese_medicine_patent
      |> cast(attrs, [:code, :medicine_type, :type, :medicine_code, :name, :name_1, :other_spec, :org_limit, :department_limit, :user_limit, :other_limit, :previous_hash, :hash, :datetime])
      |> unique_constraint(:hash)
    # Block.create_data_record(chinese_medicine_patent, changeset, "chinese_medicine_patent")
    changeset
  end
end
