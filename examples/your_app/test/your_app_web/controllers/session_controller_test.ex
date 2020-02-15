defmodule YourAppWeb.SessionControllerTest do
  use YourAppWeb.ConnCase

  setup do
    {:ok, user} = Entrance.User.create(%{email: "test@test.com", password: "test"})

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

    %{logged_in_conn: logged_in_conn}
  end

  test "YourAppWeb.SessionController.create/2", %{logged_in_conn: logged_in_conn} do
    assert "/" = redirected_to(conn, 302)
  end

  #test "YourAppWeb.SessionController.delete/2", %{logged_in_conn: logged_in_conn} do
    #assert html_response(response, 200)
  #end
end
