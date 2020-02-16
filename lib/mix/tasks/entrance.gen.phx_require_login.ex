defmodule Mix.Tasks.Entrance.Gen.PhxRequireLogin do
  @shortdoc "Creates phoenix require login plug for authentication with entrance"
  @moduledoc "Creates phoenix require login plug for authentication with entrance"

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
      |___|_|_|_| |_| |__,|_|_|___|___|.gen.phx_require_login
      """)
    end

    IO.puts("... Preparing require login plug")

    context = Inflector.call("Plugs.#{get_context(args)}RequireLogin")

    create_require_login_plug(context)
    create_require_login_plug_test(context)

    IO.puts("")
  end

  defp create_require_login_plug(context) do
    copy_template("require_login.eex", "lib/#{context[:web_path]}/#{context[:path]}.ex",
      context: context
    )
  end

  defp create_require_login_plug_test(context) do
    copy_template("require_login_test.eex", "test/#{context[:web_path]}/#{context[:path]}_test.exs",
      context: context
    )
  end

  defp copy_template(name, final_path, opts) do
    Mix.Generator.copy_template("priv/templates/gen/phx_modules/#{name}", final_path, opts)
  end

  defp get_context(["--context", module]), do: "#{Inflector.call(module)[:scoped]}."
  defp get_context([]), do: ""
end
