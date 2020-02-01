defmodule Entrance.Config do
  def config(name) do
    case Application.get_env(:entrance, name) do
      nil ->
        raise """
        You must add `#{Atom.to_string(name)}` to `entrance` in your config

        Here is an example configuration:

          config :entrance,
            repo: YourApp.Repo,
            security_module: Entrance.Auth.Bcrypt,
            user_module: YourApp.Accounts.User,
            default_authenticable_field: :email
        """

      module ->
        module
    end
  end
end
