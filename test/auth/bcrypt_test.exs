defmodule Entrance.Auth.BcryptTest do
  use Entrance.ConnCase, async: true

  alias Entrance.Auth.Bcrypt, as: EntranceBcrypt
  alias Bcrypt

  defmodule FakeUser do
    use Ecto.Schema
    import Ecto.Changeset

    schema "fake_users" do
      field(:hashed_password)
      field(:password, :string, virtual: true)
    end

    def changeset(changes) do
      %__MODULE__{}
      |> cast(changes, [:password])
      |> EntranceBcrypt.hash_password()
    end
  end

  describe "Bcrypt.hash_password/0" do
    test "sets encrypted password on changeset when virtual field is present" do
      changeset = FakeUser.changeset(%{password: "foobar"})

      assert changeset.changes[:hashed_password]
    end

    test "does not set encrypted password on changeset when virtual field is not present" do
      changeset = FakeUser.changeset(%{})

      refute changeset.changes[:hashed_password]
    end
  end

  describe "Bcrypt.authenticate/2" do
    test "authenticate returns true when password matches" do
      password = "secure"
      user = %FakeUser{hashed_password: Bcrypt.hash_pwd_salt(password)}

      assert EntranceBcrypt.authenticate(user, password)
    end

    test "authenticate returns false when password does not match" do
      password = "secure"
      user = %FakeUser{hashed_password: Bcrypt.hash_pwd_salt(password)}

      refute EntranceBcrypt.authenticate(user, "wrong")
    end
  end
end
