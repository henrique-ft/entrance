defmodule Entrance.Auth.SecretTest do
  use ExUnit.Case, async: true

  alias Entrance.Auth.Secret

  defmodule FakeUser do
    use Ecto.Schema
    import Ecto.Changeset

    schema "fake_users" do
      field(:session_secret, :string)
    end

    def changeset(_changes) do
      change(%__MODULE__{})
    end
  end

  describe "Secret.put_session_secret/2" do
    test "does generate an random session key" do
      changeset = FakeUser.changeset(%{}) |> Secret.put_session_secret()
      assert changeset.changes[:session_secret]
    end

    test "does generate different random session keys for users" do
      changeset = FakeUser.changeset(%{}) |> Secret.put_session_secret()
      changeset2 = FakeUser.changeset(%{}) |> Secret.put_session_secret()
      assert changeset.changes.session_secret != changeset2.changes.session_secret
    end

    test "does generate different random session keys for the same user" do
      changeset = FakeUser.changeset(%{}) |> Secret.put_session_secret()
      changeset2 = changeset |> Secret.put_session_secret()
      assert changeset.changes.session_secret != changeset2.changes.session_secret
    end
  end
end
