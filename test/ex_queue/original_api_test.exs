defmodule ExQueue.OriginalApiTest do
  use ExUnit.Case

  setup do
    empty = ExQueue.new()
    numbers = ExQueue.new() |> ExQueue.push("one") |> ExQueue.push("two")
    {:ok, %{empty: empty, numbers: numbers}}
  end

  test "new/0 returns an empty queue" do
    assert ExQueue.new() |> ExQueue.is_empty
  end

  test "push/2 inserts an item into the rear of the queue" do
    q = ExQueue.new
    q = ExQueue.push(q, "one")
    q = ExQueue.push(q, "two")
    assert 2 == ExQueue.len(q)
  end

  test "push_r/2 inserts an item into the rear of the queue" do
    q = ExQueue.new
    q = ExQueue.push_r(q, "one")
    q = ExQueue.push_r(q, "two")
    assert 2 == ExQueue.len(q)
  end

  describe "is_empty/1" do
    test "returns true for an empty queue", %{empty: q} do
      assert ExQueue.is_empty(q)
    end

    test "returns false for a non-empty queue", %{numbers: q} do
      refute ExQueue.is_empty(q)
    end
  end

  describe "is_queue/1" do
    test "returns true for an ExQueue" do
      q = ExQueue.new
      assert ExQueue.is_queue(q)
    end

    test "returns false otherwise" do
      refute ExQueue.is_queue('q')
    end
  end

  test "from_list/1" do
    l = [1,2,3,4,5]
    q = ExQueue.from_list(l)
    assert 5 == ExQueue.len(q)
  end

  test "to_list/1" do
    q = ExQueue.new
    q = ExQueue.push(q, "one")
    q = ExQueue.push(q, "two")
    l = ExQueue.to_list(q)
    assert ["one", "two"] == l
  end

  test "member/2" do
    q = ExQueue.new
    q = ExQueue.push(q, "one")
    q = ExQueue.push(q, "two")
    assert ExQueue.member(q, "one")
    refute ExQueue.member(q, "eno")
  end

  test "join/2" do
    q = ExQueue.new
    q = ExQueue.push(q, "one")
    q = ExQueue.push(q, "two")

    q2 = ExQueue.new
    q2 = ExQueue.push(q2, "three")
    q2 = ExQueue.push(q2, "four")

    q3 = ExQueue.join(q, q2)
    l = ExQueue.to_list(q3)

    assert ["one", "two", "three", "four"] == l
  end

  test "filter/2" do
    q = ExQueue.new
    q = ExQueue.push(q, "one")
    q = ExQueue.push(q, "two")
    q = ExQueue.push(q, "three")
    q = ExQueue.push(q, "four")

    q = ExQueue.filter(q, fn w -> String.length(w) == 3 end)
    l = ExQueue.to_list(q)
    assert ["one", "two"] == l
  end

  describe "split/2" do
    test "with an empty queue" do
      q = ExQueue.new
      assert {:error, :invalid_split} = ExQueue.split(q, 3)
      {q2, q3} = ExQueue.split(q, 0)
      assert ExQueue.is_empty(q2)
      assert ExQueue.is_empty(q3)
    end

    test "down the middle" do
      q = ExQueue.new
      q = ExQueue.push(q, "one")
      q = ExQueue.push(q, "two")
      q = ExQueue.push(q, "three")
      q = ExQueue.push(q, "four")
      {q2, q3} = ExQueue.split(q, 3)
      assert ["one", "two", "three"] = ExQueue.to_list(q2)
      assert ["four"] = ExQueue.to_list(q3)
    end

    test "greater than range" do
      q = ExQueue.new
      q = ExQueue.push(q, "one")
      q = ExQueue.push(q, "two")
      q = ExQueue.push(q, "three")
      q = ExQueue.push(q, "four")
      assert {:error, :invalid_split} == ExQueue.split(q, 5)
    end
  end

  test "reverse/1" do
    q = ExQueue.new
    q = ExQueue.push(q, "one")
    q = ExQueue.push(q, "two")
    q = ExQueue.push(q, "three")
    q = ExQueue.push(q, "four")
    q = ExQueue.reverse(q)

    assert ["four", "three", "two", "one"] == ExQueue.to_list(q)
  end

  test "pop/1" do
    q = ExQueue.new
    q = ExQueue.push(q, "one")
    q = ExQueue.push(q, "two")
    {{:value, "one"}, q} = ExQueue.pop(q)
    {{:value, "two"}, q} = ExQueue.pop(q)
    {:empty, q} = ExQueue.pop(q)
    assert ExQueue.is_empty(q)
  end

  test "pop_r/1" do
    q = ExQueue.new
    q = ExQueue.push(q, "one")
    q = ExQueue.push(q, "two")
    {{:value, "two"}, q} = ExQueue.pop_r(q)
    {{:value, "one"}, q} = ExQueue.pop_r(q)
    {:empty, q} = ExQueue.pop(q)
    assert ExQueue.is_empty(q)
  end
end
