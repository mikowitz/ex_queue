defmodule ExQueue.OkasakiApiTest do
  use ExUnit.Case

  setup do
    empty = ExQueue.new()
    numbers = ExQueue.from_list([1,2,3,4,5])
    {:ok, %{empty: empty, numbers: numbers}}
  end

  describe "Okasaki API" do
    test "cons/2", %{numbers: numbers} do
      q = ExQueue.cons(numbers, 0)
      assert [0,1,2,3,4,5] == ExQueue.to_list(q)
    end

    test "daeh/1", %{empty: empty, numbers: numbers} do
      assert 5 == ExQueue.daeh(numbers)

      assert :empty == ExQueue.daeh(empty)
    end

    test "head/1", %{empty: empty, numbers: numbers} do
      assert 1 == ExQueue.head(numbers)

      assert :empty == ExQueue.head(empty)
    end

    test "init/1", %{empty: empty, numbers: numbers} do
      assert [1,2,3,4] == ExQueue.init(numbers) |> ExQueue.to_list

      assert :empty == ExQueue.init(empty)
    end

    test "lait/1", %{empty: empty, numbers: numbers} do
      assert [1,2,3,4] == ExQueue.lait(numbers) |> ExQueue.to_list

      assert :empty == ExQueue.lait(empty)
    end

    test "last/1", %{empty: empty, numbers: numbers} do
      assert 5 == ExQueue.last(numbers)

      assert :empty == ExQueue.last(empty)
    end

    test "liat/1", %{empty: empty, numbers: numbers} do
      assert [1,2,3,4] == ExQueue.liat(numbers) |> ExQueue.to_list

      assert :empty == ExQueue.liat(empty)
    end

    test "snoc/2", %{empty: empty, numbers: numbers} do
      assert [1,2,3,4,5,6] == ExQueue.snoc(numbers, 6) |> ExQueue.to_list

      assert [6] == ExQueue.snoc(empty, 6) |> ExQueue.to_list
    end

    test "tail/1", %{empty: empty, numbers: numbers} do
      assert [2,3,4,5] == ExQueue.tail(numbers) |> ExQueue.to_list

      assert :empty == ExQueue.tail(empty)
    end
  end
end
