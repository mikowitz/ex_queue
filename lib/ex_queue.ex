defmodule ExQueue do
  @moduledoc """

  An elixir port of Erlang's [`queue`](http://erlang.org/doc/man/queue.html)
  library, providing the same API with 2 primary changes:

  * Argument order is reversed to make the queue object the first parameter,
    allowing for Elixir-style function piping
  * `:queue.in/2` and `:queue.out/1` have been replaced with `ExQueue.push/2`
    and `ExQueue.pop/1`, as well as their `_r` variants.


  ## Example Usage

      iex> q = ExQueue.new
      iex> ExQueue.len(q)
      0
      iex> q = ExQueue.push(q, "one")
      ...>   |> ExQueue.push_r("zero")
      ...>   |> ExQueue.push("two")
      iex> ExQueue.len(q)
      3
      iex> {{:value, "zero"}, q} = ExQueue.pop(q)
      iex> {{:value, "two"}, q} = ExQueue.pop_r(q)
      iex> {{:value, "one"}, q} = ExQueue.pop(q)
      iex> {:empty, _} = ExQueue.pop(q)
      iex> ExQueue.is_empty(q)
      true

  """
  defstruct queue: nil

  @typedoc "The ExQueue type"
  @type t :: %__MODULE__{queue: :queue.queue(any())}

  ## Original API

  @doc """
  Returns a new, empty queue

      iex> ExQueue.new() |> ExQueue.is_empty()
      true

  """
  def new do
    :queue.new() |> wrap_in_struct
  end

  @doc """
  Returns a new queue containing only the values in `ex_queue`
  for which `fun/1` returns true.

      iex> q = ExQueue.from_list([1,2,3,4,5])
      iex> q2 = ExQueue.filter(q, &Integer.is_even/1)
      iex> ExQueue.len(q2)
      2

  """
  def filter(%__MODULE__{queue: q}, fun) do
    :queue.filter(fun, q) |> wrap_in_struct
  end

  @doc """
  Returns a new queue containing the elements in `list`

      iex> q = ExQueue.from_list([1,2,3,4,5])
      iex> {{:value, ret}, _} = ExQueue.pop(q)
      iex> ret
      1

  """
  def from_list(list) when is_list(list) do
    :queue.from_list(list) |> wrap_in_struct
  end

  @doc """
  Inserts `item` at the end of `ex_queue`

      iex> q = ExQueue.from_list([1,2,3,4])
      iex> q = ExQueue.push(q, 0)
      iex> ExQueue.to_list(q)
      [1,2,3,4,0]

  """
  def push(%__MODULE__{queue: q}, item) do
    :queue.in(item, q) |> wrap_in_struct
  end

  @doc """
  Inserts `item` at the front of `ex_queue`

      iex> q = ExQueue.from_list([1,2,3,4])
      iex> q = ExQueue.push_r(q, 0)
      iex> ExQueue.to_list(q)
      [0,1,2,3,4]

  """
  def push_r(%__MODULE__{queue: q}, item) do
    :queue.in_r(item, q) |> wrap_in_struct
  end

  @doc """
  Returns true if `ex_queue` is empty, false otherwise

      iex> ExQueue.new() |> ExQueue.is_empty()
      true

      iex> ExQueue.new()
      ...>   |> ExQueue.push("one")
      ...>   |> ExQueue.is_empty()
      false

  """
  def is_empty(%__MODULE__{queue: q}) do
    :queue.is_empty(q)
  end

  @doc """
  Returns true if `ex_queue` is an instance of `ExQueue` and
  `ex_queue.queue` is an erlang queue, false otherwise

      iex> ExQueue.new() |> ExQueue.is_queue
      true

      iex> "ExQueue.new()" |> ExQueue.is_queue
      false

      iex> %ExQueue{queue: ":queue.new()"} |> ExQueue.is_queue
      false

  """
  def is_queue(%__MODULE__{queue: q}) do
    :queue.is_queue(q)
  end
  def is_queue(_ex_queue), do: false

  @doc """
  Returns a new queue containing the contents of `ex_queue1` in front
  of the contents of `ex_queue2`

      iex> q1 = ExQueue.from_list([1,2,3])
      iex> q2 = ExQueue.from_list([4,5,6])
      iex> ExQueue.join(q1, q2) |> ExQueue.to_list()
      [1,2,3,4,5,6]

  """
  def join(%__MODULE__{queue: q}, %__MODULE__{queue: q2}) do
    :queue.join(q, q2) |> wrap_in_struct
  end

  @doc """
  Returns the length of `ex_queue`

      iex> q = ExQueue.new()
      iex> ExQueue.len(q)
      0

      iex> q = ExQueue.from_list([1,2,3,4])
      iex> ExQueue.len(q)
      4

  """
  def len(%{queue: queue}) do
    :queue.len(queue)
  end

  @doc """
  Returns true if `ex_queue` contains `item`, false otherwise

      iex> q = ExQueue.from_list([1,2,3])
      iex> ExQueue.member(q, 2)
      true
      iex> ExQueue.member(q, 5)
      false

  """
  def member(%__MODULE__{queue: q}, item) do
    :queue.member(item, q)
  end

  @doc """
  Removes the item at the front of `ex_queue`, returning
  `{{:value, item}, queue}`, or `{:empty, queue}` if `ex_queue` is empty.

      iex> q = ExQueue.from_list([1,2])
      iex> {{:value, ret}, q} = ExQueue.pop(q)
      iex> ret
      1
      iex> {{:value, ret}, q} = ExQueue.pop(q)
      iex> ret
      2
      iex> {ret, _} = ExQueue.pop(q)
      iex> ret
      :empty

  """
  def pop(%__MODULE__{queue: q}) do
    with {ret, queue} <- :queue.out(q) do
      {ret, wrap_in_struct(queue)}
    end
  end

  @doc """
  Removes the item at the back of `ex_queue`, returning
  `{{:value, item}, queue}`, or `{:empty, queue}` if `ex_queue` is empty.

      iex> q = ExQueue.from_list([1,2])
      iex> {{:value, ret}, q} = ExQueue.pop_r(q)
      iex> ret
      2
      iex> {{:value, ret}, q} = ExQueue.pop_r(q)
      iex> ret
      1
      iex> {ret, _} = ExQueue.pop_r(q)
      iex> ret
      :empty

  """
  def pop_r(%__MODULE__{queue: q}) do
    with {ret, queue} <- :queue.out_r(q) do
      {ret, wrap_in_struct(queue)}
    end
  end

  @doc """
  Returns a new queue containing the items of `ex_queue` in reverse order

      iex> q = ExQueue.from_list([1,2,3,4])
      iex> q |> ExQueue.reverse |> ExQueue.to_list
      [4,3,2,1]

  """
  def reverse(%__MODULE__{queue: q}) do
    :queue.reverse(q) |> wrap_in_struct
  end

  @doc """
  Splits `ex_queue` into two new queues, one containing the first `n` elements
  of `ex_queue`, and the second containing the remaining elements.

      iex> q = ExQueue.from_list([1,2,3,4,5])
      iex> {q2, q3} = ExQueue.split(q, 4)
      iex> ExQueue.to_list(q2)
      [1,2,3,4]
      iex> ExQueue.to_list(q3)
      [5]

  `ExQueue.split/2` returns an error tuple if `n` is less than zero
  or is greater than the length of `ex_queue`

      iex> q = ExQueue.from_list([1,2,3,4,5])
      iex> ExQueue.split(q, -1)
      {:error, :invalid_split}
      iex> ExQueue.split(q, 7)
      {:error, :invalid_split}

  However, `split/2` can return an empty queue on either side of the split:

      iex> q = ExQueue.from_list([1,2,3])
      iex> {q2, _} = ExQueue.split(q, 0)
      iex> ExQueue.is_empty(q2)
      true

      iex> q = ExQueue.from_list([1,2,3])
      iex> {_, q2} = ExQueue.split(q, 3)
      iex> ExQueue.is_empty(q2)
      true

  """
  def split(ex_queue = %__MODULE__{queue: q}, n) do
    case n >= 0 and n <= len(ex_queue) do
      true ->
        with {q2, q3} <- :queue.split(n, q) do
          {wrap_in_struct(q2), wrap_in_struct(q3)}
        end
      false ->
        {:error, :invalid_split}
    end
  end

  @doc """
  Returns a list containing the same elements as the queue,
  with the front of the queue as the head of the list

      iex> q = ExQueue.new()
      ...>   |> ExQueue.push("one")
      ...>   |> ExQueue.push("two")
      ...>   |> ExQueue.push("three")
      iex> ExQueue.to_list(q)
      ["one", "two", "three"]

  """
  def to_list(%__MODULE__{queue: q}) do
    :queue.to_list(q)
  end

  ## Extended API

  @doc """
  Returns the queue that is the result of removing
  the front item from `ex_queue`.

      iex> q = ExQueue.from_list([1,2,3,4,5])
      iex> q |> ExQueue.drop() |> ExQueue.to_list
      [2,3,4,5]

  Returns `:empty` if `ex_queue` is empty

      iex> ExQueue.new() |> ExQueue.drop
      :empty

  """
  def drop(%__MODULE__{queue: q}) do
    try do
      :queue.drop(q) |> wrap_in_struct
    rescue
      ErlangError -> :empty
    end
  end

  @doc """
  Returns the queue that is the result of removing
  the last item from `ex_queue`

      iex> q = ExQueue.from_list([1,2,3,4,5])
      iex> q |> ExQueue.drop_r() |> ExQueue.to_list
      [1,2,3,4]

  Returns `:empty` if `ex_queue` is empty

      iex> ExQueue.new() |> ExQueue.drop
      :empty

  """
  def drop_r(%__MODULE__{queue: q}) do
    try do
      :queue.drop_r(q) |> wrap_in_struct
    rescue
      ErlangError -> :empty
    end
  end

  @doc """
  Returns the front item of a queue, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.get()
      1

      iex> ExQueue.new() |> ExQueue.get()
      :empty

  """
  def get(%__MODULE__{queue: q}) do
    try do
      :queue.get(q)
    rescue
      ErlangError -> :empty
    end
  end

  @doc """
  Returns the last item of a queue, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.get_r()
      3

      iex> ExQueue.new() |> ExQueue.get_r()
      :empty

  """
  def get_r(%__MODULE__{queue: q}) do
    try do
      :queue.get_r(q)
    rescue
      ErlangError -> :empty
    end
  end

  @doc """
  Returns a tuple `{:value, item}, where `item` is the front item of a queue,
  or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.peek()
      {:value, 1}

      iex> ExQueue.new() |> ExQueue.peek()
      :empty

  """
  def peek(%__MODULE__{queue: q}) do
    :queue.peek(q)
  end

  @doc """
  Returns a tuple `{:value, item}`, where `item` is the last item of a queue,
  or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.peek_r()
      {:value, 3}

      iex> ExQueue.new() |> ExQueue.peek_r()
      :empty

  """
  def peek_r(%__MODULE__{queue: q}) do
    :queue.peek_r(q)
  end

  defp wrap_in_struct(q) do
    %__MODULE__{queue: q}
  end
end
