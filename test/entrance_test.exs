defmodule EntranceTest do
  use Entrance.ConnCase
  doctest Entrance

  @valid_email "joe@dirt.com"
  @valid_alternate_email "brandy@dirt.com"

  defmodule FakeSuccessRepo do
    def get_by(OtherFake, email: "brandy@dirt.com") do
      %{
        email: "brandy@dirt.com",
        hashed_password: Bcrypt.hash_pwd_salt("password")
      }
    end

    def get_by(Fake, email: "joe@dirt.com") do
      %{
        email: "joe@dirt.com",
        hashed_password: Bcrypt.hash_pwd_salt("password")
      }
    end

    def get_by(Fake, email: _email), do: nil

    def get(Fake, id) do
      if id == 1 do
        %{
          email: "joe@dirt.com",
          hashed_password: Bcrypt.hash_pwd_salt("password")
        }
      else
        nil
      end
    end
  end

  test "authenticate/3 takes valid email and valid password and returns true" do
    Application.put_all_env(
      entrance: [
        repo: FakeSuccessRepo,
        user_module: Fake,
        secure_with: Entrance.Auth.Bcrypt
      ]
    )

    assert Entrance.authenticate(@valid_email, "password").email == @valid_email
  end

  test "authenticate/3 takes invalid email and valid password and returns nil" do
    Application.put_all_env(
      entrance: [
        repo: FakeSuccessRepo,
        user_module: Fake,
        secure_with: Entrance.Auth.Bcrypt
      ]
    )

    assert Entrance.authenticate("fake", "password") == nil
  end

  test "authenticate/3 takes valid email and invalid password and returns nil" do
    Application.put_all_env(
      entrance: [
        repo: FakeSuccessRepo,
        user_module: Fake,
        secure_with: Entrance.Auth.Bcrypt
      ]
    )

    assert Entrance.authenticate(@valid_email, "wrong") == nil
  end

  test "authenticate/3 takes an optional user module" do
    Application.put_all_env(
      entrance: [
        repo: FakeSuccessRepo,
        user_module: Fake,
        secure_with: Entrance.Auth.Bcrypt
      ]
    )

    user = Entrance.authenticate(OtherFake, @valid_alternate_email, "password")
    assert user.email == @valid_alternate_email
  end

  test "login/1 returns true if the user is logged in" do
    conn =
      %Plug.Conn{}
      |> Plug.Conn.assign(:current_user, %{})

    assert Entrance.logged_in?(conn)
  end

  test "login/1 returns false if the current_user is nil" do
    conn =
      %Plug.Conn{}
      |> Plug.Conn.assign(:current_user, nil)

    refute Entrance.logged_in?(conn)
  end

  test "login/1 returns false if the current_user is not present" do
    conn = %Plug.Conn{}

    refute Entrance.logged_in?(conn)
  end
end
