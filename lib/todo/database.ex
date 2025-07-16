defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @worker_ids [0, 1, 2]

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  @spec get(any()) :: any()
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    workers_pool = @worker_ids
    |> Enum.reduce(%{}, fn (index, acc) ->
      {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
      Map.put(acc, index, pid)
    end)

    {:ok, workers_pool}
  end

  def show_pool() do
    GenServer.call(__MODULE__, :pool)
  end

  def handle_call(:pool, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:store, key, data}, state) do
    key
    |> file_name()
    |> File.write(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_call({:get, key}, _, state) do
    data = case File.read(file_name(key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, state}
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
