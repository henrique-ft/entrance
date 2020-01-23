defmodule Entrance.Auth.Bcrypt do
  @moduledoc """
  Provides functions for hashing passwords and authenticating users using
  [Bcrypt](https://hexdocs.pm/bcrypt_elixir/Bcrypt.html#content).

  This module assumes that you have a virtual field named `password`, and a
  database backed string field named `hashed_password`.

  ## Usage

  ## Example

  ```
  defmodule User do
    import Entrance.Auth.Bcrypt, only: [hash_password: 1]

    import Ecto.Changeset

    def create_changeset(struct, changes) do
      struct
        |> cast(changes, ~w(email password))
        |> hash_password
    end
  end
  ```

  To authenticate a user in your application, you can use `authenticate/2`:

  ```
  user = Repo.get(User, 1)
  User.authenticate(user, "password")
  ```
  """
  alias Ecto.Changeset

  @doc """
  Takes a changeset and turns the virtual `password` field into a
  `hashed_password` change on the changeset.
  """
  def hash_password(changeset) do
    password = Changeset.get_change(changeset, :password)

    if password do
      hashed_password = Bcrypt.hash_pwd_salt(password)

      changeset
      |> Changeset.put_change(:hashed_password, hashed_password)
    else
      changeset
    end
  end

  @doc """
  Compares the given `password` against the given `user`'ss password.
  """
  def authenticate(user, password) do
    Bcrypt.verify_pass(password, user.hashed_password)
  end

  @doc """
  Simulates password check to help prevent timing attacks. Delegates to
  `Bcrypt.no_user_verify/0`.
  """
  def no_user_verify() do
    Bcrypt.no_user_verify()
  end
end
