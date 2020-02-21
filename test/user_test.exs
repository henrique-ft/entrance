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
    def create_changeset(user, attrs) do
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
    def create_changeset(user, attrs) do
      user
      |> cast(attrs, [:email, :nickname, :admin, :password, :hashed_password, :session_secret])
      |> validate_required([:email, :password])
      |> hash_password
    end
  end

  defmodule FakeRepo do
    def insert(%Ecto.Changeset{valid?: true} = create_changeset) do
      {:ok, Map.merge(create_changeset.data, create_changeset.changes)}
    end

    def insert(%Ecto.Changeset{valid?: false} = create_changeset) do
      {:error, create_changeset}
    end

    def insert!(%Ecto.Changeset{valid?: true} = create_changeset) do
      Map.merge(create_changeset.data, create_changeset.changes)
    end

    def insert!(%Ecto.Changeset{valid?: false}) do
      raise "oops"
    end
  end

  describe "User.create_changeset/0" do
    test "returns user_module create_changeset" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert create_changeset = Entrance.User.create_changeset()
    end
  end

  describe "User.create_changeset/1" do
    test "returns user_module create_changeset" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert create_changeset = Entrance.User.create_changeset(AnotherFakeUser)
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

    test "given wrong params return create_changeset error" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert {:error, create_changeset} = Entrance.User.create(%{"password" => "secret123"})
      refute is_nil(create_changeset.errors)
    end
  end

  describe "User.create!/2" do
    test "given correct user params, create an user and sets session_secret" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert user = Entrance.User.create!(%{"email" => "hello@test.com", "password" => "secret123"})

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

      assert %AnotherFakeUser{} = user =
               Entrance.User.create!(AnotherFakeUser, %{
                 "email" => "hello@test.com",
                 "password" => "secret123"
               })

      assert user.email == "hello@test.com"
      assert user.password == "secret123"
      refute is_nil(user.session_secret)
    end

    test "given wrong params raise an error" do
      Application.put_all_env(
        entrance: [
          repo: FakeRepo,
          user_module: FakeUser,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: :email
        ]
      )

      assert_raise RuntimeError, "oops", fn -> Entrance.User.create!(%{"password" => "secret123"}) end
    end
  end
end
