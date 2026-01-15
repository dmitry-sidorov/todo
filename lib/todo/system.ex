defmodule Todo.System do
  def start_link do
    IO.puts("Starting system supervisor.")
    Supervisor.start_link([Todo.Cache], strategy: :one_for_one)
  end
end
