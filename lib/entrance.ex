defmodule Entrance do
  import Ecto.Query

  @moduledoc """
  Provides authentication helpers that take advantage of the options configured
  in your config files.
  """

  @doc """
  Authenticates an user by the default authenticable field (defined in your configurations) and password. Returns the user if the
  user is found and the password is correct, otherwise nil. For example, if the default authenticable field configured is `:email`, it will try match with the `:email` field of user schema.

  Requires `user_module`, `security_module`, `repo` and `default_authenticable_field` to be configured via
  `Mix.Config`.

  ```
  Entrance.auth("joe@dirt.com", "brandyr00lz")
  ```

  If you want to authenticate other modules, you can pass in the module directly.

  ```
  Entrance.auth(Customer, "brandy@dirt.com", "super-password")
  ```
  """
  def auth(user_module \\ nil, field_value, password) do
    user_module = user_module || get_user_module()
    user = repo_module().get_by(user_module, [{default_authenticable_field(), field_value}])

    auth_result(user, password)
  end

  @doc """
  Authenticates an user by checking more than one field. Returns the user if the
  user is found and the password is correct, otherwise nil.

  Requires `user_module`, `security_module`, and `repo` to be configured via
  `Mix.Config`.

  ```
  Entrance.auth_by([email: "joe@dirt.com", admin: true], "brandyr00lz")
  ```

  If you want to authenticate other modules, you can pass in the module directly.

  ```
  Entrance.auth_by(Customer, [nickname: "truehenrique", admin: true], "super-password")
  ```
  """
  def auth_by(user_module \\ nil, fields_values, password) do
    unless Keyword.keyword?(fields_values) do
      raise """
      Entrance.auth_by/2 must receive a keyword list

      Here is some examples:

        Entrance.auth_by([email: "joe@dirt.com", admin: true], "brandyr00lz")
        Entrance.auth_by(Customer, [email: "joe@dirt.com", admin: true], "brandyr00lz")
      """
    end

    user_module = user_module || get_user_module()
    user = repo_module().get_by(user_module, fields_values)

    auth_result(user, password)
  end

  @doc """
  Receives an atom list as fields list, a value and a password. Authenticates a user by at least one field in the fields list. Returns the user if the
  user is found and the password is correct, otherwise nil.

  Requires `user_module`, `security_module`, and `repo` to be configured via
  `Mix.Config`.

  ```
  Entrance.auth_one([:email, :nickname], "my-nickname", "my-password")
  ```

  If you want to authenticate other modules, you can pass in the module directly.

  ```
  Entrance.auth_one(Customer, [:nickname, :email], "my@email.com", "my-password")
  ```
  """
  def auth_one(user_module \\ nil, [first_field | fields], value, password) do
    user_module = user_module || get_user_module()

    Enum.reduce(fields, from(um in user_module, where: ^[{first_field, value}]), fn field,
                                                                                    query ->
      or_where(query, [um], ^[{field, value}])
    end)
    |> repo_module().one()
    |> auth_result(password)
  end

  @doc """
  Authenticates a user. Returns true if the user's password and the given
  password match based on the `security_module` strategy configured, otherwise false.

  Requires `user_module`, `security_module`, and `repo` to be configured via
  `Mix.Config`.

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

  defp auth_result(user, password) do
    cond do
      user && auth_user(user, password) ->
        user

      true ->
        security_module().no_user_verify()
        nil
    end
  end

  defp repo_module, do: get_module(:repo)

  defp get_user_module, do: get_module(:user_module)

  defp security_module, do: get_module(:security_module)

  defp default_authenticable_field, do: get_module(:default_authenticable_field)

  defp get_module(name) do
    case Application.get_env(:entrance, name) do
      nil ->
        raise """
        You must add `#{Atom.to_string(name)}` to `entrance` in your config

        Here is an example configuration:

          config :entrance,
            repo: MyApp.Repo,
            security_module: Entrance.Auth.Bcrypt,
            user_module: MyApp.Accounts.User,
            default_authenticable_field: :email
        """

      module ->
        module
    end
  end
end
