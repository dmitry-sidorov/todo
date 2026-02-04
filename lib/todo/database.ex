defmodule Todo.Database do
  @pool_size 3
  @db_folder "./persist"

  def start_link(_) do
    IO.puts("Starting database supervisor.")
    File.mkdir_p!(@db_folder)

    children = 1..@pool_size |> Enum.map(&worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}

    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor,
     }
  end
end
