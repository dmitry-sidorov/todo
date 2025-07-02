defmodule TodoListTest do
  use ExUnit.Case
  alias Todo.{List}

  describe "new" do
    test "should create empty list by default" do
      assert %List{} = List.new()
    end

    test "should create prefilled list" do
      initial_entries = [
        %{date: ~D[2025-01-10], title: "Birthday"},
        %{date: ~D[2025-03-07], title: "Wife's birthday"}
      ]
      expected = %List{
        entries: %{
          1 => Enum.at(initial_entries, 0) |> Map.put(:id, 1),
          2 => Enum.at(initial_entries, 1) |> Map.put(:id, 2)
        },
        next_id: 3
      }
      assert expected == List.new(initial_entries)
    end
  end
end
