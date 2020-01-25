defmodule YourAppWeb.PageController do
  use YourAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", %{current_user: conn.assigns[:current_user] || %{}})
  end

  def secret(conn, _params) do
    render(conn, "secret.html", %{current_user: conn.assigns[:current_user]})
  end
end
