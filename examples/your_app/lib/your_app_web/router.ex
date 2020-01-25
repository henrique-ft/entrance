defmodule YourAppWeb.Router do
  use YourAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers

    plug Entrance.Login.Session
  end

  pipeline :protected do
    plug YourApp.Plugs.RequireLogin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/secret", YourAppWeb do
    pipe_through :browser
    pipe_through :protected

    get "/", PageController, :secret
  end

  scope "/", YourAppWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/users/new", UserController, :new
    post "/users/new", UserController, :create

    get "/session/new", SessionController, :new
    post "/session/new", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", YourAppWeb do
  #   pipe_through :api
  # end
end
