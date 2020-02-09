defmodule Entrance.User do
  @moduledoc """
    This module provider helpers functions for your app users management
  """
  alias Entrance.Auth.Secret

  import Entrance.Config, only: [config: 1]

  @doc """
  Execute this behind the scenes:
  ```
    alias Entrance.Auth.Secret

    # ...
    %YourUser{}
    |> YourUser.changeset(your_user_params)
    |> Secret.put_session_secret()
    |> YourRepo.insert()
  ```

  Returns `{:ok, user}` or `{:error, changeset}`

  Requires `user_module` (when not setting user module directly) and `repo` to be configured via
  `Mix.Config`.

  # Examples

  ```
  {:ok, user} = Entrance.User.create(%{"email => "joe@dirt.com", "password" => "brandyr00lz"})
  ```

  If you want to create with other user schemas, you can pass in the module directly.

  ```
  {:ok, customer} = Entrance.User.create(Customer, %{"email => "joe@dirt.com", "password" => "brandyr00lz"})
  ```
  """
  def create(user_module \\ nil, user_params) do
    user_module = user_module || config(:user_module)

    struct(user_module)
    |> user_module.changeset(user_params)
    |> Secret.put_session_secret()
    |> config(:repo).insert()
  end

  @doc """
  Execute this behind the scenes:
  ```
    YourUser.changeset(%YourUser{}, %{})
  ```

  Returns and `Ecto.Changeset` struct

  Requires `user_module` to be configured via `Mix.Config`.

  # Example

  ```
    # YourAppWeb.UserController ...
    def new(conn, _params) do
      conn |> render("new.html", changeset: Entrance.User.changeset)
    end
  ```
  """
  def changeset do
    user_module = config(:user_module)
    user_module.changeset(struct(user_module), %{})
  end

  @doc """
  Similar to `Entrance.User.changeset/0` but not needs the `user_module` to be configured via `Mix.Config`

  # Example

  ```
    # YourAppWeb.UserController ...
    def new(conn, _params) do
      conn |> render("new.html", changeset: Entrance.User.changeset(Customer))
    end
  ```
  """
  def changeset(user_module) do
    user_module.changeset(struct(user_module), %{})
  end
end
