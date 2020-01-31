defmodule Entrance.Login.Session do
  use Entrance.Login

  @session_key :user_id
  @session_secret :session_secret

  @doc """
  Logs in given user by setting `:user_id` on the session of passed in `conn`. The user struct must have an `:session_secret` field.

  ## Example

  ```
  import Entrance.Login.Session

  # ... your controller
  user = Repo.get(User, 1)

  conn
  |> login(user)
  |> put_flash(:notice, "Successfully logged in")
  |> redirect(to: "/")
  ```
  """
  def login(conn, user) do
    conn
    |> Plug.Conn.put_session(@session_key, user.id)
    |> Plug.Conn.put_session(@session_secret, user.session_secret)
  end

  @doc """
  Logs out current user.

  ## Example

  ```
  import Entrance.Login.Session

  # ... your controller
  conn
  |> logout
  |> put_flash(:notice, "Successfully logged out")
  |> redirect(to: "/")
  ```
  """
  def logout(conn) do
    conn
    |> Plug.Conn.delete_session(@session_key)
    |> Plug.Conn.delete_session(@session_secret)
  end

  @doc """
  Returns the current user or nil based on `:user_id` in the session.

  ## Example

  ```
  import Entrance.Login.Session

  # ... your controller
  login(conn, Repo.get(User, 1))

  user = get_current_user(conn)
  ```
  """
  def get_current_user(conn) do
    id = Plug.Conn.get_session(conn, @session_key)

    if !is_nil(id) do
      secret = Plug.Conn.get_session(conn, @session_secret)
      repo = Application.get_env(:entrance, :repo)
      user_module = Application.get_env(:entrance, :user_module)
      repo.get_by(user_module, id: id, session_secret: secret)
    end
  end
end
