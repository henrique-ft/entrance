defmodule YourApp.Repo do
  use Ecto.Repo,
    otp_app: :your_app,
    adapter: Ecto.Adapters.Postgres
end
