defmodule Entrance.User do
  @moduledoc """
    This module provider helpers function for your app users management
  """
  alias Entrance.Auth.Secret

  import Entrance.Config, only: [config: 1]

  def create(user_module \\ nil, user_params) do
    user_module = user_module || config(:user_module)

    struct(user_module)
    |> user_module.changeset(user_params)
    |> Secret.put_session_secret()
    |> config(:repo).insert()
  end
end
