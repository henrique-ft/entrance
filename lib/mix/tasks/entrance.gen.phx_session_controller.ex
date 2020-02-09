defmodule Mix.Tasks.Entrance.Gen.PhxSessionController do
  @shortdoc "Creates phoenix session controller for authentication with entrance"

  alias Entrance.Mix.Phoenix.Inflector
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
      |___|_|_|_| |_| |__,|_|_|___|___|.gen.phx_session_controller
      """)
    end

    IO.puts("... Preparing session controller")

    base_context = get_context(args)

    create_session_controller(base_context)
    create_session_view(base_context)
    create_session_controller_test(base_context)
    create_session_view_test(base_context)

    IO.puts("")
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


  defp copy_template(name, final_path, opts) do
    Mix.Generator.copy_template("priv/templates/gen/phx_modules/#{name}", final_path, opts)
  end

  defp get_context(["--context", module]), do: "#{Inflector.call(module)[:scoped]}."
  defp get_context([]), do: ""
end
