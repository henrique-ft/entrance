defmodule Mix.Tasks.Entrance.Gen.PhxModules do
  alias Entrance.Phoenix.Inflector
  use Mix.Task

  @shortdoc "Simply runs the Hello.say/0 function"
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

    base_context = get_context(args)

    create_user_controller(base_context)
    create_user_view(base_context)

    create_session_controller(base_context)
    create_session_view(base_context)

    create_require_login_plug(base_context)

    create_user_controller_test(base_context)
    create_user_view_test(base_context)

    create_session_controller_test(base_context)
    create_session_view_test(base_context)

    create_require_login_plug_test(base_context)
  end

  def create_user_controller(base_context) do
    context = Inflector.call("#{base_context}UserController")

    copy_template(
      "user_controller.eex",
      "lib/#{context[:web_path]}/controllers/#{context[:path]}.ex",
      context: context
    )
  end

  def create_user_controller_test(base_context) do
    context = Inflector.call("#{base_context}UserControllerTest")

    copy_template(
      "user_controller_test.eex",
      "test/#{context[:web_path]}/controllers/#{context[:path]}.ex",
      context: context
    )
  end

  def create_user_view(base_context) do
    context = Inflector.call("#{base_context}UserView")

    copy_template("user_view.eex", "lib/#{context[:web_path]}/views/#{context[:path]}.ex",
      context: context
    )
  end

  def create_user_view_test(base_context) do
    context = Inflector.call("#{base_context}UserViewTest")

    copy_template("user_view_test.eex", "test/#{context[:web_path]}/views/#{context[:path]}.ex",
      context: context
    )
  end

  def create_session_controller(base_context) do
    context = Inflector.call("#{base_context}SessionController")

    copy_template(
      "session_controller.eex",
      "lib/#{context[:web_path]}/controllers/#{context[:path]}.ex",
      context: context
    )
  end

  def create_session_controller_test(base_context) do
    context = Inflector.call("#{base_context}SessionControllerTest")

    copy_template(
      "session_controller_test.eex",
      "test/#{context[:web_path]}/controllers/#{context[:path]}.ex",
      context: context
    )
  end

  def create_session_view(base_context) do
    context = Inflector.call("#{base_context}SessionView")

    copy_template("session_view.eex", "lib/#{context[:web_path]}/views/#{context[:path]}.ex",
      context: context
    )
  end

  def create_session_view_test(base_context) do
    context = Inflector.call("#{base_context}SessionViewTest")

    copy_template(
      "session_view_test.eex",
      "test/#{context[:web_path]}/views/#{context[:path]}.ex",
      context: context
    )
  end

  def create_require_login_plug(base_context) do
    context = Inflector.call("Plugs.#{base_context}RequireLogin")

    copy_template("require_login.eex", "lib/#{context[:web_path]}/#{context[:path]}.ex",
      context: context
    )
  end

  def create_require_login_plug_test(base_context) do
    context = Inflector.call("Plugs.#{base_context}RequireLoginTest")

    copy_template("require_login_test.eex", "test/#{context[:web_path]}/#{context[:path]}.ex",
      context: context
    )
  end

  defp copy_template(name, final_path, opts) do
    Mix.Generator.copy_template("priv/templates/gen/phx_modules/#{name}", final_path, opts)
  end

  defp get_context(["--context", module]), do: "#{Inflector.call(module)[:scoped]}."
  defp get_context([]), do: ""
end
