defmodule EntranceTest do
  use Entrance.ConnCase
  doctest Entrance

  @default_authenticable_field :email
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

    def get_by(Fake, email: email, other_field: other_field) do
      send(self(), {email, other_field})

      %{
        email: "joe@dirt.com",
        other_field: other_field,
        hashed_password: Bcrypt.hash_pwd_salt("password")
      }
    end

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

  describe "Entrance.authenticate/3" do
    test "takes valid email and valid password and returns true" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt,
          default_authenticable_field: @default_authenticable_field
        ]
      )

      assert Entrance.authenticate(@valid_email, "password").email == @valid_email
    end

    test "raises error whith wrong configurations" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt,
          default_authenticable_field: nil
        ]
      )

      assert_raise RuntimeError, ~r/You must add `default_authenticable_field` to `entrance`/, fn ->
        Entrance.authenticate(@valid_email, "password")
      end
    end

    test "takes invalid email and valid password and returns nil" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt,
          default_authenticable_field: @default_authenticable_field
        ]
      )

      assert Entrance.authenticate("fake", "password") == nil
    end

    test "takes valid email and invalid password and returns nil" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt,
          default_authenticable_field: @default_authenticable_field
        ]
      )

      assert Entrance.authenticate(@valid_email, "wrong") == nil
    end

    test "takes an optional user module" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt,
          default_authenticable_field: @default_authenticable_field
        ]
      )

      user = Entrance.authenticate(OtherFake, @valid_alternate_email, "password")
      assert user.email == @valid_alternate_email
    end
  end

  describe "Entrance.authenticate_by/3" do
    test "raise error when second params is not an keyword list" do
      assert_raise RuntimeError, ~r/must receive a keyword list/, fn ->
        Entrance.authenticate_by("not a keyword list", "password")
      end
    end

    test "takes valid email and valid password and returns true" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt
        ]
      )

      assert Entrance.authenticate_by([email: @valid_email], "password").email == @valid_email
    end

    test "takes invalid email and valid password and returns nil" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt
        ]
      )

      assert Entrance.authenticate_by([email: "fake"], "password") == nil
    end

    test "receives others fields for authentication match" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt
        ]
      )

      assert Entrance.authenticate_by(
               [email: @valid_email, other_field: "some_value"],
               "password"
             ).email == @valid_email

      assert_received {@valid_email, "some_value"}
    end

    test "takes valid email and invalid password and returns nil" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt
        ]
      )

      assert Entrance.authenticate_by([email: @valid_email], "wrong") == nil
    end

    test "takes an optional user module" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          secure_with: Entrance.Auth.Bcrypt
        ]
      )

      user = Entrance.authenticate_by(OtherFake, [email: @valid_alternate_email], "password")
      assert user.email == @valid_alternate_email
    end
  end

  describe "Entrance.login/1" do
    test "returns true if the user is logged in" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.assign(:current_user, %{})

      assert Entrance.logged_in?(conn)
    end

    test "returns false if the current_user is nil" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.assign(:current_user, nil)

      refute Entrance.logged_in?(conn)
    end

    test "returns false if the current_user is not present" do
      conn = %Plug.Conn{}

      refute Entrance.logged_in?(conn)
    end
  end
end
