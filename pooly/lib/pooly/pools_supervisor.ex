defmodule Pooly.PoolsSupervisor do
  use Supervisor

  def start_link do
    # Again we only have ONE PoolsSupervisor
    # so we make it a named process
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    # The children will be of type PoolSupervisor
    # A crash in any of the Pools should not affect the others
    # that is why we choose the one_for_one strategy
    opts = [
      strategy: :one_for_one
    ]

    # We have to validate the pools_config before creating any pool
    # so we do not have any children at start.
    supervise([], opts)
  end
end
