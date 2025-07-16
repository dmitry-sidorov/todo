defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_dirname) do
    GenServer.start(__MODULE__, db_dirname)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def init(db_dirname) do
    File.mkdir_p!(db_dirname)
    {:ok, {:db_dirname, db_dirname}}
  end

  def handle_cast({:store, key, data}, {:db_dirname, db_dirname} = state) do
    file_name(db_dirname, key)
    |> File.write(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_call({:get, key}, _, {:db_dirname, db_dirname} = state) do
    data = case File.read(file_name(db_dirname, key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, state}
  end

  defp file_name(db_dirname, key) do
    Path.join(db_dirname, to_string(key))
  end
end
