defmodule YourApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Entrance.Auth.Bcrypt, only: [hash_password: 1]

  schema "users" do
    field :email, :string
    # Add this line
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :session_secret, :string

    timestamps()
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    # Dont forget to add :password here
    |> cast(attrs, [:email, :password, :hashed_password, :session_secret])
    # And here
    |> validate_required([:email, :password])
    # Add this
    |> hash_password
  end
end
