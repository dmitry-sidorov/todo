defmodule TodoCacheTest do
  use ExUnit.Case
  alias Todo.{Cache, Server}

  test "server_process" do
    {:ok, cache} = Cache.start()
    bob_pid = Cache.server_process(cache, "bob")

    assert bob_pid != Cache.server_process(cache, "alice")
    assert bob_pid == Cache.server_process(cache, "bob")
  end

  test "to-do operations" do
    mock_date = ~D[2018-12-19]
    mock_entry = %{date: mock_date, title: "Dentist"}
    {:ok, cache} = Cache.start()
    alice = Cache.server_process(cache, "alice")
    Server.add_entry(alice, mock_entry)
    entries = Server.entries(alice, mock_date)

    assert [mock_entry] = entries
  end
end
