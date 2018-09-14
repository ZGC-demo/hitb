defmodule BlockWeb.ServerServiceController do
  use BlockWeb, :controller
  plug BlockWeb.Access
  alias Block.ServerService
  alias Block.Repo

  def server_service(conn, _) do
    server_service = Repo.all(ServerService)
    server_service = Enum.map(server_service, fn x ->
      Map.drop(x, [:__meta__, :__struct__])
    end)
    json(conn,  %{server_service: server_service})
  end
end
