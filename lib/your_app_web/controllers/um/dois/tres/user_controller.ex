defmodule EntranceWeb.Um.Dois.Tres.UserController do
  use EntranceWeb, :controller
  alias YourApp.Repo

  alias Entrance.Auth.Secret
  alias Elixir.YourApp.Accounts.User

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    conn |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset =
      %User{}
      |> User.changeset(user_params)
      |> Secret.put_session_secret()

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn |> redirect(to: "/")
      {:error, changeset} ->
        conn |> render("new.html", changeset: changeset)
    end
  end
end
