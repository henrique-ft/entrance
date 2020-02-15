defmodule YourAppWeb.PageControllerTest do
  use YourAppWeb.ConnCase

  import Entrance.Login.Session, only: [login: 2]

  alias Entrance.Auth.Secret

  alias YourApp.Accounts.User
  alias YourApp.Repo

  setup do
    changeset =
      %User{}
      |> User.changeset(%{email: "test@test.com", password: "test"})
      |> Secret.put_session_secret()

    {:ok, user} = Repo.insert(changeset)

    opts =
      Plug.Session.init(
        store: :cookie,
        key: "test_key",
        encryption_salt: "test_encryption_salt",
        signing_salt: "test_signing_salt",
        log: false,
        encrypt: false
      )

    logged_in_conn =
      build_conn()
      |> Plug.Session.call(opts)
      |> fetch_session()
      |> login(user)

    %{logged_in_conn: logged_in_conn}
  end

  test "GET /protected", %{logged_in_conn: logged_in_conn} do
    response =
      logged_in_conn
      |> get("/protected")

    assert html_response(response, 200)
  end
end
