defmodule Entrance.UserTest do
  use Entrance.ConnCase

  defmodule AnotherFakeUser do
    use Ecto.Schema
    import Ecto.Changeset
    import Entrance.Auth.Bcrypt, only: [hash_password: 1]

    schema "users" do
      field(:email, :string)
      field(:nickname, :string)
      field(:admin, :boolean)
      field(:other_field, :string)
      field(:password, :string, virtual: true)
      field(:hashed_password, :string)
      field(:session_secret, :string)
    end

    @doc false
    def changeset(user, attrs) do
      user
      |> cast(attrs, [:email, :nickname, :admin, :password, :hashed_password, :session_secret])
      |> validate_required([:email, :password])
      |> hash_password
    end
  end

  defmodule FakeUser do
    use Ecto.Schema
    import Ecto.Changeset
    import Entrance.Auth.Bcrypt, only: [hash_password: 1]

    schema "users" do
      field(:email, :string)
      field(:nickname, :string)
      field(:admin, :boolean)
      field(:other_field, :string)
      field(:password, :string, virtual: true)
      field(:hashed_password, :string)
      field(:session_secret, :string)
    end

    @doc false
    def changeset(user, attrs) do
      user
      |> cast(attrs, [:email, :nickname, :admin, :password, :hashed_password, :session_secret])
      |> validate_required([:email, :password])
      |> hash_password
    end
  end

  defmodule FakeRepo do
    def insert(%Ecto.Changeset{valid?: true} = changeset) do
      {:ok, Map.merge(changeset.data, changeset.changes)}
    end

    def insert(%Ecto.Changeset{valid?: false} = changeset) do
      {:error, changeset}
    end
  end

  describe "User.changeset/0" do
    test "returns user_module changeset" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert changeset = Entrance.User.changeset()
    end
  end

  describe "User.changeset/1" do
    test "returns user_module changeset" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert changeset = Entrance.User.changeset(AnotherFakeUser)
    end
  end

  describe "User.create/2" do
    test "given correct user params, create an user and sets session_secret" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert {:ok, user} =
               Entrance.User.create(%{"email" => "hello@test.com", "password" => "secret123"})

      assert user.email == "hello@test.com"
      assert user.password == "secret123"
      refute is_nil(user.session_secret)
    end

    test "given correct user params with another user, create an user and sets session_secret" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert {:ok, %AnotherFakeUser{} = user} =
               Entrance.User.create(AnotherFakeUser, %{
                 "email" => "hello@test.com",
                 "password" => "secret123"
               })

      assert user.email == "hello@test.com"
      assert user.password == "secret123"
      refute is_nil(user.session_secret)
    end

    test "given wrong params return changeset error" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert {:error, changeset} = Entrance.User.create(%{"password" => "secret123"})
      refute is_nil(changeset.errors)
    end
  end
end
