defmodule Mix.Tasks.Entrance.Gen.PhxScaffold do
  import Entrance.Config, only: [config: 1]
  alias Entrance.Phoenix.Inflector
  use Mix.Task

  @shortdoc "Simply runs the Hello.say/0 function"
  def run(args) do
    #IO.inspect(config(:user_module))
    IO.inspect(args)
    IO.inspect(Inflector.call(List.first(args)))
  end
end
