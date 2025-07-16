defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @worker_ids [0, 1, 2]

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    choose_worker(key) |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    choose_worker(key) |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl true
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

  @impl true
  def handle_call(:pool, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:choose_worker, key}, _, pool) do
    worker_id = :erlang.phash2(key, 3)
    worker = Map.get(pool, worker_id)

    {:reply, worker, pool}
  end
end
