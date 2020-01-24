# Entrance

Entrance is a modern, updated and maintained version of [Doorman](https://github.com/BlakeWilliams/doorman). 

> Modules and functions to make authentication with Plug/Phoenix and Ecto easy without tons of configuration or boxing users into rigid framework.
> 
> The primary goal is to build an opinionated interface and easy to use API on top of flexible modules that can also be used directly.

You can find more in-depth [documentation here](https://hexdocs.pm/entrance/)

## Installation

Add entrance to your dependencies in `mix.exs`.

```elixir
def deps do
  [{:entrance, "~> 0.1.0"}]
end
```

Then add the configuration to `config/config.exs`

```elixir
config :entrance,              
  repo: YourApp.Repo,
  security_module: Entrance.Auth.Bcrypt,
  user_module: YourApp.Accounts.User,
  default_authenticable_field: :email
```
## Phoenix Quick Start

First, generate a user schema with a `hashed_password:string` and `session_secret:string` field:

`$ mix phx.gen.schema Accounts.User users email:string hashed_password:string session_secret:string`

Run the migrations:

`$ mix ecto.migrate`

Next, use `Entrance.Auth.Bcrypt` in your new `User` module and add a virtual `:password` field. `hash_password/1` is used in the changeset to hash our password and put it into the changeset as `:hashed_password`.

```elixir
defmodule YourApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Entrance.Auth.Bcrypt, only: [hash_password: 1]

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true # Add this line
    field :hashed_password, :string
    field :session_secret, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :hashed_password, :session_secret]) # Dont forget to add :password here
    |> validate_required([:email, :password]) # And here
    |> hash_password # Add this line
  end
end
```

Finally, we can add our plug so we can have access to `current_user` on `conn.assigns[:current_user]`. 99% of the time that means adding the `Entrance.Login.Session` plug to your `:browser` pipeline:

```elixir
  pipeline :browser do
    # ...

    plug Entrance.Login.Session
  end 
```

### Creating Users

To create a user we can use the `YourApp.Accounts.User.create_changeset/2` function we defined. Here we'll also add the `session_secret` to the user, which is only needed when creating an user or in case of compromised sessions.

```elixir
defmodule YourAppWeb.UserController do
  use YourAppWeb, :controller
  alias YourApp.Repo    
    
  alias Entrance.Auth.Secret
  alias YourApp.Accounts.User
    
  def new(conn, _params) do    
    changeset = User.changeset(%User{}, %{})
    conn |> render("new.html", changeset: changeset)
  end
    
  def create(conn, %{"user" => user_params}) do
    changeset =
      %User{}                  
      |> User.changeset(user_params)  
      |> Secret.put_session_secret()  
    
    case Repo.insert(changeset) do  
      {:ok, _user} ->
        conn |> redirect(to: "/")       
      {:error, changeset} ->
        conn |> render("new.html", changeset: changeset)
    end 
  end   
end  
```

### Logging in users

To login users we can use `Entrance.auth` and `Entrance.Login.Session.login/2`.

```elixir
defmodule YourAppWeb.SessionController do
  use YourAppWeb, :controller
  import Entrance.Login.Session, only: [login: 2]

  def new(conn, _params) do
    render(conn, "new.html")
  end 

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    if user = Entrance.auth(email, password) do
      conn
      |> login(user) # Sets :user_id and :session_secret on conn's session
      |> put_flash(:notice, "Successfully logged in")
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:error, "No user found with the provided credentials")
      |> render("new.html")
    end 
  end 
end
```

You can also use `Entrance.auth_by` if your authentication needs more fields matching the user schema:

```elixir
Entrance.auth_by([email: email, admin: true], password)
```

*Note: In this README example, we did not create the `:admin` field in `Accounts.User` schema*

Read more about `Entrance` "auth functions" variations [here](https://hexdocs.pm/entrance/Entrance.html#content), and find what can fit more to your needs.

### Requiring Authentication

To require a user to be authenticated you can build a simple plug around `Entrance.logged_in?/1`.

```elixir
defmodule YourApp.Plugs.RequireLogin do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if Entrance.logged_in?(conn) do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: "/session/new")
      |> halt
    end
  end
end
```

An example in *your_app/lib/your_app_web/router.ex*:

```elixir
pipeline :secret do
  plug YourApp.Plugs.RequireLogin
end 

# ...

scope "/secret", YourAppWeb do
  pipe_through :browser
  pipe_through :secret

  get "/", PageController, :secret
end 

# ...
```

### Logout users

To logout users we can use `Entrance.Login.Session.logout/1`

```elixir
defmodule YourAppWeb.SessionController do 
  use YourAppWeb, :controller  
  import Entrance.Login.Session, only: [login: 2, logout: 1] # Import logout
          
  def new(conn, _params) do
    render(conn, "new.html")   
  end 
      
  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    if user = Entrance.auth(email, password) do
      conn
      |> login(user)           
      |> put_flash(:notice, "Successfully logged in")
      |> redirect(to: "/")     
    else  
      conn
      |> put_flash(:error, "No user found with the provided credentials")
      |> render("new.html")    
    end   
  end   
        
  # Add delete function to your sessions controller
  def delete(conn, _params) do 
    conn
    |> logout # Use logout function
    |> put_flash(:notice, "Successfully logged out")
    |> redirect(to: "/")       
  end
end 
```

## Contribute

I'm totally open to new ideas. Fork, open issues and feel free to contribute.
