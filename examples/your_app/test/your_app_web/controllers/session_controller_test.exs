defmodule YourAppWeb.SessionControllerTest do
  @moduledoc """
    Ajust the tests conform your app configuration :)
  """

  @test_user_email "test@test.com"
  @test_user_password "test"
  @logout_route "/logout"
  @login_route "/session/new"

  use YourAppWeb.ConnCase
  import Entrance.Login.Session, only: [login: 2]

  setup do
    {:ok, user} = Entrance.User.create(%{email: @test_user_email, password: @test_user_password})

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

    %{session_conn: session_conn, user: user}
  end

  describe "YourAppWeb.SessionController.create/2" do
    @tag :skip
    test "when login succed, sets the user_id in session and redirect with notice", %{
      session_conn: session_conn,
      user: user
    } do
      params = %{"session" => %{"email" => @test_user_email, "password" => @test_user_password}}

      conn =
        session_conn
        |> post(@login_route, params)

      expected_plug_session = %{
        "phoenix_flash" => %{"notice" => "Successfully logged in"},
        "user_id" => user.id
      }

      assert "/" = redirected_to(conn, 302)
      assert expected_plug_session["phoenix_flash"] == conn.private.plug_session["phoenix_flash"]
      assert expected_plug_session["user_id"] == conn.private.plug_session["user_id"]
    end

    @tag :skip
    test "when login fails put error flash", %{session_conn: session_conn, user: user} do
      params = %{"session" => %{"email" => "fail", "password" => "fail"}}

      conn =
        session_conn
        |> post(@login_route, params)

      assert %{"error" => "No user found with the provided credentials"} ==
        conn.private[:phoenix_flash]
    end

    @tag :skip
    test "YourAppWeb.SessionController.delete/2", %{session_conn: session_conn, user: user} do
      conn =
        session_conn
        |> login(user)
        |> delete(@logout_route)

      assert "/" = redirected_to(conn, 302)
      assert %{"notice" => "Successfully logged out"} == conn.private[:phoenix_flash]
      assert nil == conn.private.plug_session["user_id"]
    end
  end
end
