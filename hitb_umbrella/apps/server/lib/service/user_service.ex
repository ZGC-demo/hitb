defmodule Server.UserService do
  import Ecto.Query
  alias Hitb.Repo
  alias Comeonin.Bcrypt
  alias Block.AccountService
  alias Hitb.Server.User
  # alias ServerWeb.MyUser

  #登录,返回conn
  def login(user, _blockchain) do
    db_user = Repo.get_by(User, username: user.username)
    cond do
      db_user == nil ->
        user = %{login: false, username: "", key: []}
        [user, false]
      Bcrypt.checkpw(user.password, db_user.hashpw) ->
        account =
          if(db_user.block_address == nil)do
            %{publicKey: "", username: ""}
          else
            %{publicKey: "", username: ""}
            # AccountService.getAccountByAddress(db_user.block_address)
          end
        blockchain = %{address: db_user.block_address, publicKey: account.publicKey, secret: account.username}
        #缓存区块链数据
        Hitb.ets_insert(:my_user, "blockchain" <> user.username, Map.merge(%{address2: ""}, blockchain))
        #缓存用户数据
        Hitb.ets_insert(:my_user, user.username, %{id: db_user.id, org: db_user.org, login: true, username: db_user.username, type: db_user.type, key: db_user.key, blockchain: blockchain})
        #返回登录
        user = %{id: db_user.id, org: db_user.org, login: true, username: db_user.username, type: db_user.type, key: db_user.key, blockchain: blockchain, is_show: db_user.is_show}
        [user, true]
      true ->
        user = %{login: false, username: "", type: 2, key: []}
        [user, false]
    end
  end

  #登录,返回conn
  def socket_login(user) do
    db_user = Repo.get_by(User, username: user.username)
    cond do
      db_user == nil ->
        [false, %{login: false, username: user.username}]
      Bcrypt.checkpw(user.password, db_user.hashpw) ->
        account =
          if(db_user.block_address == nil)do
            %{publicKey: "", username: ""}
          else
            case AccountService.getAccountByAddress(db_user.block_address) do
              nil -> AccountService.getAccountByAddress("pkryhTdUUwH2ZXlgRii1XHp6ECdSu9jwsNFSXVOeNU")
              account -> account
            end
          end
        # blockchain = %{address: db_user.block_address, publicKey: account.publicKey, secret: account.username}
        user = %{id: db_user.id, org: db_user.org, login: true, username: db_user.username, type: db_user.type, key: db_user.key, blockchain: account, is_show: db_user.is_show}
        [true, user]
      true ->
        [false, %{login: false, username: user.username}]
    end
  end

  #退出,返回conn
  def logout() do
    %{login: false, username: nil}
  end

  #登录状态,返回是否登录
  def is_login(user) do
    case user do
      nil -> false
      _ -> true
    end
  end

  #返回用户信息
  def user_info(user) do
    cond do
      user == nil -> %{login: false, username: "", type: 2, key: []}
      user.username == nil or user.username == "" ->  %{login: false, username: "", type: 2, key: []}
      true -> Repo.get_by(User, username: user.username)
    end
  end

  def all_user() do
    Repo.all(from p in User, select: p.username)
  end

  def list_user(page, num) do
    skip = Hitb.Page.skip(page, 15)
    query = from(w in User)
      |> limit([w], ^num)
      |> offset([w], ^skip)
      |> Repo.all
    count = hd(Repo.all(from p in User, select: count(p.id)))
    [count, query]
  end

  def create_user(attrs \\ %{}) do
    username = attrs["username"]
    get_user = Repo.get_by(User, username: username)
    case get_user do
      nil ->
        attrs = Map.merge(%{"hashpw" => Bcrypt.hashpwsalt(attrs["password"]), "type" => 2, "key" => []}, attrs)
        #调用block服务
        secret = generate_secret(username)|>Enum.join(" ")
        block_address = AccountService.newAccount(%{username: secret, balance: 0})
        case block_address do
          false ->
            attrs = Map.merge(%{"hashpw" => Bcrypt.hashpwsalt(attrs["password"]), "is_show" => false}, attrs)
            changeset = User.changeset(%User{}, attrs)
            {:error, changeset}
          _ ->
            attrs = Map.merge(%{"block_address" => block_address.address}, attrs)
            %User{}
            |> User.changeset(attrs)
            |> Repo.insert()
        end
      _ ->
        attrs = Map.merge(%{"hashpw" => Bcrypt.hashpwsalt(attrs["password"]), "is_show" => false}, attrs)
        changeset = User.changeset(%User{}, attrs)
        # changeset = %{changeset | :errors => ["error": "用户名已存在！"]}
        {:error, changeset}
    end
  end

  def get_user!(id), do: Repo.get!(User, id)

  def update_user(id, attrs) do
    attrs =
      if (attrs["password"]) do
        Map.merge(%{"hashpw" => Bcrypt.hashpwsalt(attrs["password"])}, attrs)
      else
        attrs
      end
    get_user!(id)
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(id) do
    user = get_user!(id)
    Repo.delete(user)
  end

  defp generate_secret(username) do
    username = String.split(username, "@")|>List.first
    words = Mnemonic.generate()|>String.split(" ")
    [username] ++ Enum.map(0..10, fn x -> Enum.at(words, x) end)
  end
end
