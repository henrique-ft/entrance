defmodule Entrance do
  @moduledoc """
  Provides authentication helpers that take advantage of the options configured
  in your config files.
  """

  @doc """
  Authenticates a user by the default authenticable field (defined in config) and password. Returns the user if the
  user is found and the password is correct, otherwise nil. For example, if the default authenticable field configured is :email, it will try match with the :email field of user schema.

  Requires `user_module`, `security_module`, `repo` and `default_authenticable_field` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  Entrance.auth("joe@dirt.com", "brandyr00lz")
  ```

  If you want to authenticate other modules, you can pass in the module directly.

  ```
  Entrance.auth(Customer, "brandy@dirt.com", "super-password")
  ```
  """
  def auth(user_module \\ nil, field, password),
    do: auth_action(user_module, [{get_default_authenticable_field(), field}], password)

  @doc """
  Similar to auth/2, but authenticates a user by one or more differents fields. Returns the user if the
  user is found and the password is correct, otherwise nil.

  Requires `user_module`, `security_module`, and `repo` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  Entrance.auth_by([email: "joe@dirt.com", admin: true], "brandyr00lz")
  ```

  If you want to authenticate other modules, you can pass in the module directly.

  ```
  Entrance.auth_by(Customer, [nickname: "truehenrique", admin: true], "super-password")
  ```
  """
  def auth_by(user_module \\ nil, fields, password) do
    unless Keyword.keyword?(fields) do
      raise """
      Entrance.authenticate_by/2 must receive a keyword list

      Here is some examples:

        Entrance.authenticate_by([email: "joe@dirt.com", admin: true], "brandyr00lz")
        Entrance.authenticate_by(Customer, [email: "joe@dirt.com", admin: true], "brandyr00lz")
      """
    end

    auth_action(user_module, fields, password)
  end

  @doc """
  Authenticates a user. Returns true if the user's password and the given
  password match based on the strategy configured, otherwise false.

  Use `auth/2` if if you would to authenticate by email and password.

  Requires `user_module`, `security_module`, and `repo` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  user = Myapp.Repo.get(Myapp.User, 1)
  Entrance.auth_user(user, "brandyr00lz")
  ```
  """
  def auth_user(user, password), do: security_module().auth(user, password)

  @doc """
  Returns true if passed in `conn`s `assigns` has a non-nil `:current_user`,
  otherwise returns false.

  Make sure your pipeline uses a login plug to fetch the current user for this
  function to work correctly..
  """
  def logged_in?(conn), do: conn.assigns[:current_user] != nil

  defp auth_action(user_module, fields, password) do
    user_module = user_module || get_user_module()
    user = repo_module().get_by(user_module, fields)

    cond do
      user && auth_user(user, password) ->
        user

      true ->
        security_module().no_user_verify()
        nil

      user ->
        nil
    end
  end

  defp repo_module, do: get_module(:repo)

  defp get_user_module, do: get_module(:user_module)

  defp security_module, do: get_module(:security_module)

  defp get_default_authenticable_field, do: get_module(:default_authenticable_field)

  defp get_module(name) do
    case Application.get_env(:entrance, name) do
      nil ->
        raise """
        You must add `#{Atom.to_string(name)}` to `entrance` in your config

        Here is an example configuration:

          config :entrance,
            repo: MyApp.Repo,
            security_module: Entrance.Auth.Bcrypt,
            user_module: MyApp.User,
            default_authenticable_field: :email
        """

      module ->
        module
    end
  end
end
