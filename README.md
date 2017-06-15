# ExQueue

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


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_queue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ex_queue, "~> 0.1.0"}]
end
```

## API

Currently this library only includes the functions included in the "Original API"

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_queue](https://hexdocs.pm/ex_queue).

