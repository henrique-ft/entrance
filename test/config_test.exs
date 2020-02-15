defmodule Entrance.ConfigTest do
  use ExUnit.Case, async: true
  import Entrance.Config

  describe "Entrance.config/1" do
    test "raises error whith wrong configurations" do
      Application.put_all_env(
        entrance: [
          repo: FakeSuccessRepo,
          user_module: Fake,
          security_module: Entrance.Auth.Bcrypt,
          default_authenticable_field: nil
        ]
      )

      assert_raise RuntimeError,
                   ~r/You must add `default_authenticable_field` to `entrance`/,
                   fn ->
                     config(:default_authenticable_field)
                   end
    end
  end
end
