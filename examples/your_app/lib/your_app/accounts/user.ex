defmodule YourApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Entrance.Auth.Bcrypt, only: [hash_password: 1]

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true # Add this line
    field :hashed_password, :string
    field :session_secret, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :hashed_password, :session_secret]) # Dont forget to add :password here
    |> validate_required([:email, :password]) # And here
    |> hash_password # Add this
  end
end
