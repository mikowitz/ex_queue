defmodule ExQueue do
  @moduledoc """

  An elixir port of Erlang's [`queue`](http://erlang.org/doc/man/queue.html)
  library.

  This library provides the same API with three major changes:

  * Argument order is made constant so that the queue object is always the
    first parameter, allowing for Elixir-style function piping
  * `:queue.in/2` and `:queue.out/1` have been replaced with `ExQueue.push/2`
    and `ExQueue.pop/1`, as well as their `_r` variants.
  * Functions that would fail with `ErlangError` when given an empty queue
    now return the atom `:empty`

  ### Original API

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


  ### Extended API

      iex> q = ExQueue.new
      ...>   |> ExQueue.push("one")
      ...>   |> ExQueue.push_r("zero")
      ...>   |> ExQueue.push("two")
      iex> q = ExQueue.drop(q)
      iex> ExQueue.get(q)
      "one"
      iex> ExQueue.peek_r(q)
      {:value, "two"}

  ### Okasaki API

      iex> q = ExQueue.new
      ...>   |> ExQueue.push("one")
      ...>   |> ExQueue.push_r("zero")
      ...>   |> ExQueue.push("two")
      iex> q = ExQueue.cons(q, "negative one")
      iex> q = ExQueue.snoc(q, "three")
      iex> ExQueue.head(q)
      "negative one"
      iex> ExQueue.daeh(q)
      "three"

  See inline documentation for more examples.

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
  @spec new :: __MODULE__.t
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
  @spec filter(__MODULE__.t, fun()) :: __MODULE__.t
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
  @spec from_list(list()) :: __MODULE__.t
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
  @spec push(__MODULE__.t, any()) :: __MODULE__.t
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
  @spec push_r(__MODULE__.t, any()) :: __MODULE__.t
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
  @spec is_empty(__MODULE__.t) :: boolean()
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
  @spec is_queue(__MODULE__.t) :: boolean()
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
  @spec join(__MODULE__.t, __MODULE__.t) :: __MODULE__.t
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
  @spec len(__MODULE__.t) :: non_neg_integer()
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
  @spec member(__MODULE__.t, any()) :: boolean()
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
  @spec pop(__MODULE__.t) :: {{:value, any()}, __MODULE__.t} | :empty
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
  @spec pop_r(__MODULE__.t) :: {{:value, any()}, __MODULE__.t} | :empty
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
  @spec reverse(__MODULE__.t) :: __MODULE__.t
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
  @spec split(__MODULE__.t, non_neg_integer()) :: {__MODULE__.t, __MODULE__.t} | {:error, :invalid_split}
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
  @spec to_list(__MODULE__.t) :: list()
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
  @spec drop(__MODULE__.t) :: __MODULE__.t | :empty
  def drop(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.drop(q) |> wrap_in_struct
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
  @spec drop_r(__MODULE__.t) :: __MODULE__.t | :empty
  def drop_r(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.drop_r(q) |> wrap_in_struct
    end
  end

  @doc """
  Returns the front item of a queue, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.get()
      1

      iex> ExQueue.new() |> ExQueue.get()
      :empty

  """
  @spec get(__MODULE__.t) :: any() | :empty
  def get(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.get(q)
    end
  end

  @doc """
  Returns the last item of a queue, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.get_r()
      3

      iex> ExQueue.new() |> ExQueue.get_r()
      :empty

  """
  @spec get_r(__MODULE__.t) :: any() | :empty
  def get_r(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.get_r(q)
    end
  end

  @doc """
  Returns a tuple `{:value, item}`, where `item` is the fron item of a queue,
  or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.peek()
      {:value, 1}

      iex> ExQueue.new() |> ExQueue.peek()
      :empty

  """
  @spec peek(__MODULE__.t) :: {:value, any()} | :empty
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
  @spec peek_r(__MODULE__.t) :: {:value, any()} | :empty
  def peek_r(%__MODULE__{queue: q}) do
    :queue.peek_r(q)
  end

  ## Okasaki API

  @doc """
  Returns a queue by adding `item` to the front of `ex_queue`

      iex> ExQueue.new() |> ExQueue.cons(1) |> ExQueue.to_list
      [1]

  """
  @spec cons(__MODULE__.t, any()) :: __MODULE__.t
  def cons(%__MODULE__{queue: q}, item) do
    :queue.cons(item, q) |> wrap_in_struct
  end

  @doc """
  Returns the last item in `ex_queue`, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.daeh
      3

      iex> ExQueue.new() |> ExQueue.daeh
      :empty

  """
  @spec daeh(__MODULE__.t) :: any() | :empty
  def daeh(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.daeh(q)
    end
  end

  @doc """
  Returns the front item from `ex_queue`, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.head
      1

      iex> ExQueue.new() |> ExQueue.head
      :empty

  """
  @spec head(__MODULE__.t) :: any() | :empty
  def head(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.head(q)
    end
  end

  @doc """
  Returns a queue containing all by the last time from `ex_queue`, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.init |> ExQueue.to_list
      [1,2]

      iex> ExQueue.new() |> ExQueue.init
      :empty

  """
  @spec init(__MODULE__.t) :: __MODULE__.t | :empty
  def init(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.init(q) |> wrap_in_struct
    end
  end

  @doc """
  Warning: this function's name is a misspelling and will be removed in a future
  release of Erlang.

  I am including it here for completeness, but don't use it. Use `liat/1` instead.
  """
  @spec lait(__MODULE__.t) :: __MODULE__.t | :empty
  def lait(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.lait(q) |> wrap_in_struct
    end
  end

  @doc """
  Returns the last item from `ex_queue`, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.last
      3

      iex> ExQueue.new() |> ExQueue.last
      :empty

  """
  @spec last(__MODULE__.t) :: any() | :empty
  def last(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.last(q)
    end
  end

  @doc """
  Returns a queue containing all but the last item from `ex_queue`, or `:empty`

      iex> ExQueue.from_list([1,2,3]) |> ExQueue.liat |> ExQueue.to_list
      [1,2]

      iex> ExQueue.new() |> ExQueue.liat
      :empty

  """
  @spec liat(__MODULE__.t) :: __MODULE__.t | :empty
  def liat(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.liat(q) |> wrap_in_struct
    end
  end

  @doc """
  Returns a new queue created by adding `item` to the end of `ex_queue`

      iex> ExQueue.from_list([1,2,3,4]) |> ExQueue.snoc(5) |> ExQueue.to_list
      [1,2,3,4,5]

  """
  @spec snoc(__MODULE__.t, any()) :: __MODULE__.t
  def snoc(%__MODULE__{queue: q}, item) do
    :queue.snoc(q, item) |> wrap_in_struct
  end

  @doc """
  Returns a queue containing all but the first item from `ex_queue`, or `:empty`

      iex> ExQueue.from_list([1,2,3,4]) |> ExQueue.tail |> ExQueue.to_list
      [2,3,4]

      iex> ExQueue.new() |> ExQueue.tail
      :empty

  """
  @spec tail(__MODULE__.t) :: __MODULE__.t | :empty
  def tail(%__MODULE__{queue: q}) do
    return_or_rescue_empty fn ->
      :queue.tail(q) |> wrap_in_struct
    end
  end

  defp wrap_in_struct(q) do
    %__MODULE__{queue: q}
  end

  defp return_or_rescue_empty(fun) do
    try do
      fun.()
    rescue
      ErlangError -> :empty
    end
  end
end
