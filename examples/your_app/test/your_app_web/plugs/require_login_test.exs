defmodule YourAppWeb.Plugs.RequireLoginTest do
  @moduledoc """
    Ajust the tests conform your app configuration :)
  """

  @login_route "/session/new"

  use YourAppWeb.ConnCase
  alias YourAppWeb.Plugs.RequireLogin

  setup do
    opts =
      Plug.Session.init(
        store: :cookie,
        key: "test_key",
        encryption_salt: "test_encryption_salt",
        signing_salt: "test_signing_salt",
        log: false,
        encrypt: false
      )

    session_conn =
      build_conn()
      |> Plug.Session.call(opts)
      |> fetch_session()
      |> fetch_flash()

    %{session_conn: session_conn}
  end

  describe "YourAppWeb.Plugs.RequireLogin.call/2" do
    @tag :skip
    test "when user is not logged in, redirect to login route", %{
      session_conn: session_conn
    } do
      assert @login_route = redirected_to(RequireLogin.call(session_conn, %{}), 302)
    end
  end
end
