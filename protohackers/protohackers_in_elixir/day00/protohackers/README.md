# Protohackers

A TCP/IP Server that accepts connections waits for all the data for the client until it closed the connection
and then send the same information back

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `protohackers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:protohackers, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/protohackers](https://hexdocs.pm/protohackers).

## Bitacora

First thing we need is a long live proccess to accept connections.
It seems like a work for `GenServer` even if we are not gonna use most of its power.
That is [./lib/protohackers/echo_server.ex]
