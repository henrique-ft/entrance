defmodule Mix.Tasks.Entrance.Gen.PhxScaffold do
  import Entrance.Config, only: [config: 1]
  alias Entrance.Phoenix.Inflector
  use Mix.Task

  @shortdoc "Simply runs the Hello.say/0 function"
  def run(args) do
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
      |___|_|_|_| |_| |__,|_|_|___|___|.gen.phx_scaffold
      """)
    base_context = get_context(args)

    IO.inspect(base_context)
    IO.inspect(Inflector.call("#{base_context}.UserController"))

    create_user_controller(base_context)
    #create_user_view(base_context)
    #create_user_templates(base_context)

    #create_session_controller(base_context)
    #create_session_view(base_context)
    #create_session_templates(base_context)

    #create_require_login_plug(base_context)
  end

  def create_user_controller(base_context) do
    context =
      Inflector.call("#{base_context}.UserController")
      |> Keyword.put(:user_module, config(:user_module))

    copy_template("user_controller.eex", "lib/your_app_web/controllers/#{context[:path]}.ex", [context: context])
  end

  def create_user_view(base_context) do
    copy_template("user_view.ex", "lib/your_app_web/views/user_view.ex", [])
  end

  def create_user_templates(base_context) do
  end

  def create_session_controller(base_context) do
    copy_template("session_controller.ex", "lib/your_app_web/controllers/sesion_controller.ex", [])
  end

  def create_session_view(base_context) do
    copy_template("session_view.ex", "lib/your_app_web/views/session_view.ex", [])
  end

  def create_session_templates(base_context) do
  end

  def create_require_login_plug(base_context) do
    copy_template("require_login.ex", "lib/your_app_web/plugs/require_login.ex", [])
  end

  defp copy_template(name, final_path, opts \\ []) do
    Mix.Generator.copy_template("priv/templates/gen/phx_scaffold/#{name}", final_path, opts)
  end

  defp get_context(["--context", module]) do
    Inflector.call(module)[:scoped]
  end
end
