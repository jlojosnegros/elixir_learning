# Pooly

Pooly manages a pool of workers.

## Versions

### Version One

Targets:

- Supports a single pool
- Supports a fixed number of workers
- No recovery when consumer and/or worker processes fail

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pooly` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pooly, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/pooly](https://hexdocs.pm/pooly).

## Examples

### Starting a Pool

In order to start a pool, you must give it a pool configuration that provides the information needed for Pooly to initialize the pool:

```elixir
pool_config = [
  mfa: {SampleWorker, :start_link, []},
  size: 5
]
```

This tells the pool to create five SampleWorkers. To start the pool, do this:

```elixir
Pooly.start_pool(pool_config)
```

### Checking out workers

In Pooly lingo, checking out a worker means requesting and getting a worker from the
pool. The return value is a pid of an available worker:

```elixir
worker_pid = Pooly.checkout
```

Once a consumer process has a worker_pid, the process can do whatever it wants with it.
What happens if no more workers are available? For now, :noproc is returned. You'll
have more sophisticated ways of handling this in later versions.

### Checking Workers back into the pool

Once a consumer process is done with the worker, the process must return it to the
pool, also known as checking in the worker. Checking in a worker is straightforward:

```elixir
Pooly.checkin(worker_pid)
```

### Getting status of the pool

It's helpful to get some useful information from the pool:

```elixir
Pooly.status
```

For now, this returns a tuple such as `{3, 2}`. This means there are three free workers
and two busy ones.

That concludes our short tour of the API.
