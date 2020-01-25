defmodule YourApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :hashed_password, :string
      add :session_secret, :string

      timestamps()
    end

  end
end
