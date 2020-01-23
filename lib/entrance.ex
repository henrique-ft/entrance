defmodule Entrance do
  @moduledoc """
  Provides authentication helpers that take advantage of the options configured
  in your config files.
  """

  @doc """
  Authenticates a user by their email and password. Returns the user if the
  user is found and the password is correct, otherwise nil.

  Requires `user_module`, `secure_with`, and `repo` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  Entrance.authenticate("joe@dirt.com", "brandyr00lz")
  ```

  If you want to authenticate other modules, you can pass in the module directly.

  ```
  Entrance.authenticate(Customer, "brandy@dirt.com", "super-password")
  ```
  """

  def authenticate(user_module \\ nil, email, password) do
    user_module = user_module || get_user_module()
    user = repo_module().get_by(user_module, email: email)

    cond do
      user && authenticate_user(user, password) ->
        user

      user ->
        nil

      true ->
        auth_module().no_user_verify()
        nil
    end
  end

  @doc """
  Authenticates a user. Returns true if the user's password and the given
  password match based on the strategy configured, otherwise false.

  Use `authenticate/2` if if you would to authenticate by email and password.

  Requires `user_module`, `secure_with`, and `repo` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  user = Myapp.Repo.get(Myapp.User, 1)
  Entrance.authenticate_user(user, "brandyr00lz")
  ```
  """
  def authenticate_user(user, password) do
    auth_module().authenticate(user, password)
  end

  @doc """
  Returns true if passed in `conn`s `assigns` has a non-nil `:current_user`,
  otherwise returns false.

  Make sure your pipeline uses a login plug to fetch the current user for this
  function to work correctly..
  """
  def logged_in?(conn) do
    conn.assigns[:current_user] != nil
  end

  defp repo_module do
    get_module(:repo)
  end

  defp get_user_module do
    get_module(:user_module)
  end

  defp auth_module do
    get_module(:secure_with)
  end

  defp get_module(name) do
    case Application.get_env(:entrance, name) do
      nil ->
        raise """
        You must add `#{Atom.to_string(name)}` to `entrance` in your config

        Here is an example configuration:

          config :entrance,
            repo: MyApp.Repo,
            secure_with: Entrance.Auth.Bcrypt,
            user_module: MyApp.User
        """

      module ->
        module
    end
  end
end
