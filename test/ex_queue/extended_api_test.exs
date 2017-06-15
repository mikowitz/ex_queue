defmodule ExQueue.ExtendedApiTest do
  use ExUnit.Case

  setup do
    empty = ExQueue.new()
    numbers = ExQueue.from_list([1,2,3,4,5])
    {:ok, %{empty: empty, numbers: numbers}}
  end

  describe "Extended API" do
    test "drop/1", %{empty: empty, numbers: numbers} do
      q = ExQueue.drop(numbers)
      assert [2,3,4,5] == ExQueue.to_list(q)

      assert :empty == ExQueue.drop(empty)
    end

    test "drop_r/1", %{empty: empty, numbers: numbers} do
      q = ExQueue.drop_r(numbers)
      assert [1,2,3,4] == ExQueue.to_list(q)

      assert :empty == ExQueue.drop_r(empty)
    end

    test "get/1", %{empty: empty, numbers: numbers} do
      assert :empty == ExQueue.get(empty)
      assert 1 == ExQueue.get(numbers)
    end

    test "get_r/1", %{empty: empty, numbers: numbers} do
      assert :empty == ExQueue.get_r(empty)
      assert 5 == ExQueue.get_r(numbers)
    end

    test "peek/1", %{empty: empty, numbers: numbers} do
      assert :empty == ExQueue.peek(empty)
      assert {:value, 1} == ExQueue.peek(numbers)
    end

    test "peek_r/1", %{empty: empty, numbers: numbers} do
      assert :empty == ExQueue.peek_r(empty)
      assert {:value, 5} == ExQueue.peek_r(numbers)
    end
  end
end
