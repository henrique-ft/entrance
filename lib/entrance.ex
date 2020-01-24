defmodule Entrance do
  @moduledoc """
  Provides authentication helpers that take advantage of the options configured
  in your config files.
  """

  @doc """
  Authenticates a user by the default authenticable field (defined in config) and password. Returns the user if the
  user is found and the password is correct, otherwise nil. For example, if the default authenticable field configured is :email, it will try match with the :email field of user schema.

  Requires `user_module`, `secure_with`, `repo` and `default_authenticable_field` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  Entrance.authenticate("joe@dirt.com", "brandyr00lz")
  ```

  If you want to authenticate other modules, you can pass in the module directly.

  ```
  Entrance.authenticate(Customer, "brandy@dirt.com", "super-password")
  ```
  """
  def authenticate(user_module \\ nil, field, password),
    do: authenticate_action(user_module, [{default_authenticable_field(), field}], password)

  @doc """
  Similar to authenticate/2, but authenticates a user by one or more differents fields. Returns the user if the
  user is found and the password is correct, otherwise nil.

  Requires `user_module`, `secure_with`, and `repo` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  Entrance.authenticate_by([email: "joe@dirt.com", admin: true], "brandyr00lz")
  ```

  If you want to authenticate other modules, you can pass in the module directly.

  ```
  Entrance.authenticate_by(Customer, [nickname: "truehenrique", admin: true], "super-password")
  ```
  """
  def authenticate_by(user_module \\ nil, fields, password) do
    unless Keyword.keyword?(fields) do
      raise """
      Entrance.authenticate_by/2 must receive a keyword list

      Here is some examples:

        Entrance.authenticate_by([email: "joe@dirt.com", admin: true], "brandyr00lz")
        Entrance.authenticate_by(Customer, [email: "joe@dirt.com", admin: true], "brandyr00lz")
      """
    end

    authenticate_action(user_module, fields, password)
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
  def authenticate_user(user, password), do: auth_module().authenticate(user, password)

  @doc """
  Returns true if passed in `conn`s `assigns` has a non-nil `:current_user`,
  otherwise returns false.

  Make sure your pipeline uses a login plug to fetch the current user for this
  function to work correctly..
  """
  def logged_in?(conn), do: conn.assigns[:current_user] != nil

  defp authenticate_action(user_module, fields, password) do
    user_module = user_module || get_user_module()
    user = repo_module().get_by(user_module, fields)

    cond do
      user && authenticate_user(user, password) ->
        user

      true ->
        auth_module().no_user_verify()
        nil

      user ->
        nil
    end
  end

  defp repo_module, do: get_module(:repo)

  defp get_user_module, do: get_module(:user_module)

  defp auth_module, do: get_module(:secure_with)

  defp default_authenticable_field, do: get_module(:default_authenticable_field)

  defp get_module(name) do
    case Application.get_env(:entrance, name) do
      nil ->
        raise """
        You must add `#{Atom.to_string(name)}` to `entrance` in your config

        Here is an example configuration:

          config :entrance,
            repo: MyApp.Repo,
            secure_with: Entrance.Auth.Bcrypt,
            user_module: MyApp.User,
            default_authenticable_field: :email
        """

      module ->
        module
    end
  end
end
