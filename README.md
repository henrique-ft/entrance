![Entrance](https://www.truehenrique.com/images/entrance_logo.png)

# Entrance

![Version](https://img.shields.io/hexpm/v/entrance?style=flat-square)
![License](https://img.shields.io/github/license/henriquefernandez/entrance?style=flat-square)
![Code Size](https://img.shields.io/github/languages/code-size/henriquefernandez/entrance?style=flat-square)

Modules and functions to make authentication with *Plug / Phoenix* and *Ecto* easy without tons of configuration or boxing users into rigid and bloated framework.
 
The primary goal of *Entrance* is to build an opinionated interface and easy to use *API* on top of flexible modules that can also be used directly.

If you like simple and beautiful code, you'd like *Entrance*.

You can find more in-depth [documentation here](https://hexdocs.pm/entrance/Entrance.html#content). 

## Table of contents

- [Installation](#installation)
- [Phoenix](#phoenix)
    - [Creating users](#creating-users)
    - [Logging in users](#logging-in-users)
    - [Requiring Authentication](#requiring-authentication)
    - [Logging out users](#logging-out-users)
    - [Testing](#testing)
- [Contribute](#contribute)
- [Credits](#credits)

### Installation

Add entrance to your dependencies in `mix.exs`.

```elixir
def deps do
  [{:entrance, "~> 0.3.0"}]
end
```

Then add the configuration to *[your_app/config/config.exs](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/config/config.exs)*

```elixir
config :entrance,              
  repo: YourApp.Repo,
  security_module: Entrance.Auth.Bcrypt,
  user_module: YourApp.Accounts.User,
  default_authenticable_field: :email
```
### Phoenix

First, generate a user schema with a `hashed_password:string` and `session_secret:string` field:

`$ mix phx.gen.schema Accounts.User users email:string hashed_password:string session_secret:string`

Run the migrations:

`$ mix ecto.migrate`

Next, use `Entrance.Auth.Bcrypt` in your new `User` module and add a virtual `:password` field. `hash_password/1` is used in the changeset to hash our password and put it into the changeset as `:hashed_password`.

*[your_app/lib/your_app/accounts/user.ex](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/lib/your_app/accounts/user.ex)*
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

Finally, we can add our plug so we can have access to *current_user* on `conn.assigns[:current_user]`. 99% of the time that means adding the `Entrance.Login.Session` plug to your `:browser` pipeline:

*[your_app/lib/your_app_web/router.ex](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/lib/your_app_web/router.ex)*
```elixir
  pipeline :browser do
    # ...

    plug Entrance.Login.Session
  end 
```

#### Creating Users

To create a user we can use the `User.changeset/2` function we defined. Here we'll also add the `session_secret` to the user, which is only needed when creating an user or in case of compromised sessions.

*[your_app/lib/your_app_web/controllers/user_controller.ex](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/lib/your_app_web/controllers/user_controller.ex)*
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

#### Logging in users

To login users we can use `Entrance.auth` and `Entrance.Login.Session.login/2`.

*[your_app/lib/your_app_web/controllers/session_controller.ex](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/lib/your_app_web/controllers/session_controller.ex)*
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

*Entrance* have some other functions that might fit well too, 

if you need...

More fields matching the user schema `Entrance.auth_by`:

```elixir
Entrance.auth_by([email: email, admin: true], password)
```

More fields matching the same value, `Entrance.auth_one`:

```elixir
Entrance.auth_one([:email, :nickname], my_nickname, password)
```

More fields matching the same value, and more fields matching the user schema `Entrance.auth_one_by`:

```elixir
Entrance.auth_one_by({[:email, :nickname], my_nickname}, [admin: true], password)
```

*Note: In this README example, we did not create the `:admin` or `:nickname` fields in `Accounts.User` schema*

Read more about *Entrance* "auth functions" variations [here](https://hexdocs.pm/entrance/Entrance.html#content).

#### Requiring Authentication

To require a user to be authenticated you can build a simple plug around `Entrance.logged_in?/1`.

*[your_app/lib/your_app_web/plugs/require_login.ex](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/lib/your_app_web/plugs/require_login.ex)*
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

An example in *[your_app/lib/your_app_web/router.ex](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/lib/your_app_web/router.ex)*:

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

#### Logging out users

To logout users we can use `Entrance.Login.Session.logout/1`

*[your_app/lib/your_app_web/controllers/session_controller.ex](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/lib/your_app_web/controllers/session_controller.ex)*
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

#### Testing

You can easily test routes that require authentication following the example below:

*[your_app/test/your_app_web/controllers/page_controller_test.exs](https://github.com/henriquefernandez/entrance/blob/master/examples/your_app/test/your_app_web/controllers/page_controller_test.exs)*
```elixir
defmodule YourAppWeb.PageControllerTest do
  use YourAppWeb.ConnCase

  import Entrance.Login.Session, only: [login: 2] # Add this line

  alias Entrance.Auth.Secret # And this line
  alias YourApp.Accounts.User
  alias YourApp.Repo

  # Setup an logged_in_conn
  setup do
    changeset =
      %User{}
      |> User.changeset(%{email: "test@test.com", password: "test"})
      |> Secret.put_session_secret()

    {:ok, user} = Repo.insert(changeset)

    opts =
      Plug.Session.init(
        store: :cookie,
        key: "test_key",
        encryption_salt: "test_encryption_salt",
        signing_salt: "test_signing_salt",
        log: false,
        encrypt: false
      )

    logged_in_conn =
      build_conn()
      |> Plug.Session.call(opts)
      |> fetch_session()
      |> login(user)

    %{logged_in_conn: logged_in_conn}
  end

  test "GET /secret", %{logged_in_conn: logged_in_conn} do
    response =
      logged_in_conn
      |> get("/secret")

    assert html_response(response, 200) # Yeah, it passes!
  end
end
```

## Contribute

*Entrance* is not only for me, but for the *Elixir* community.

I'm totally open to new ideas. Fork, open issues and feel free to contribute with no bureaucracy. We only need to keep some patterns to maintain an organization:

#### branchs

*your_branch_name*

#### commits

*[your_branch_name] Your commit*

## Credits

Entrance was built upon [Doorman](https://github.com/BlakeWilliams/doorman). Thanks to [Blake Williams](https://github.com/blakewilliams) & [Ashley Foster](https://github.com/AshleyFoster).

For the logo, thanks to [Melissa Moreira](https://github.com/melissamoreira).


