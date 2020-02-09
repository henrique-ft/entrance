defmodule Entrance.User do
  @moduledoc """
    This module provider helper function for your app users management
  """
  alias Entrance.Auth.Secret

  import Entrance.Config, only: [config: 1]

  def create(user_params) do
    user = config(:user_module)

    %user{}
    |> user.changeset(user_params)
    |> Secret.put_session_secret()
    |> config(:repo).insert()
  end
end
