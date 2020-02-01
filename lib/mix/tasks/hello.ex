defmodule Mix.Tasks.Hello do
  import Entrance.Config, only: [config: 1]
  use Mix.Task

  @shortdoc "Simply runs the Hello.say/0 function"
  def run(_) do
    IO.inspect(config(:user_module))
  end
end
