defmodule HitbserverWeb.HelpController do
  use HitbserverWeb, :controller
  alias Edit.HelpService
  # alias Hitb.Time
  plug HitbserverWeb.Access
  def help_insert(conn, _params) do
    %{"name" => name, "content" => content} = Map.merge(%{"name" => "", "content" => ""}, conn.params)
    HelpService.help_insert(name, content)
    json conn, %{success: true}
  end
  def help_list(conn, _params) do
    result = HelpService.help_list()
    json conn, %{result: result, success: true}
  end

  def help_file(conn, _params) do
    %{"name" => _name} = Map.merge(%{"name" => ""}, conn.params)
    result = HelpService.help_file()
    json conn, %{result: result, success: true}
  end

end
