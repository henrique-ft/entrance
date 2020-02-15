defmodule Mix.Tasks.Entrance.Gen.PhxModules do
  @shortdoc "Creates phoenix modules for authentication with entrance (session_controller, user_controller, views and plugs/require_login"

  @moduledoc """
  Creates phoenix modules for authentication with entrance (session_controller, user_controller and plugs/require_login).

      mix entrance.gen.phx_modules

  This generator will add the following files to `lib/`:
      * a controller in `lib/your_app_web/controllers/user_controller.ex`
      * a view in `lib/your_app_web/views/user_view.ex`
      * a controller in `lib/your_app_web/controllers/session_controller.ex`
      * a view in `lib/your_app_web/views/session_view.ex`
      * a plug in `lib/your_app_web/plugs/require_login.ex`

  And also a test file for each of this files.

  you can also set the modules context

      mix entrance.gen.phx_modules --context Accounts

  With "--context Accounts" creates:
      * a controller in `lib/your_app_web/controllers/accounts/user_controller.ex`
      * a view in `lib/your_app_web/views/accounts/user_view.ex`
      * a controller in `lib/your_app_web/controllers/accounts/session_controller.ex`
      * a view in `lib/your_app_web/views/accounts/session_view.ex`
      * a plug in `lib/your_app_web/plugs/accounts/require_login.ex`
  """
  use Mix.Task

  @doc false
  def run(io_puts \\ true, args) do
    if io_puts == true do
      IO.puts("""
      ---hMMd---NMM/--yMMN---oMMh---
      ---hMMd---NMM/--yMMN---oMMh---
      ---+sso---oss:--+sso---/ss+---
      ------------------------------
      ------------------------------
      ----------/+oosyyso+/---------
      ------:yddyso++++++symdo:-----
      ----:hdo/:::::::::::::+hm/----
      ---:my::::::::::::::::::ym:---
      ---yd::::::::::::::::::::N+---
      ---hy::::::::::::::::::::N+---
      ---hy::::::::::::::::::::N+---
      ---hy::::::::::::::::::::N+---
      ---hy::::::::::::::::::::Nh---
      ---hy::::::::::::::::::::Nh---
      ---hy::::::::::::::::::::Nh---
      ---hy::::::::::::://+ooyyNh---
      ---hh++ossyhhmmNNNMMMMMMMMh---
       ___ ___| |_ ___ ___ ___ ___ ___
      | -_|   |  _|  _| .'|   |  _| -_|
      |___|_|_|_| |_| |__,|_|_|___|___|.gen.phx_modules
      """)
    end

    Mix.Tasks.Entrance.Gen.PhxUserController.run(false, args)
    Mix.Tasks.Entrance.Gen.PhxSessionController.run(false, args)
    Mix.Tasks.Entrance.Gen.PhxRequireLogin.run(false, args)
  end
end
