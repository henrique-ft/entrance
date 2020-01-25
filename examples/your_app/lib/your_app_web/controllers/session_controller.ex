defmodule YourAppWeb.SessionController do
  use YourAppWeb, :controller
  import Entrance.Login.Session, only: [login: 2, logout: 1]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    if user = Entrance.auth(email, password) do
      conn
      |> login(user)
      |> put_flash(:notice, "Successfully logged in")
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:error, "No user found with the provided credentials")
      |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> logout # This line
    |> put_flash(:notice, "Successfully logged out")
    |> redirect(to: "/")
  end
end
