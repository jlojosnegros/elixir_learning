defmodule Pooly.PoolSupervisor do
  use Supervisor

  def start_link(pool_config) do
    Supervisor.start_link(__MODULE__, pool_config, name: :"#{pool_config[:name]}Supervisor")
  end

  def init(pool_config) do
    opts = [
      strategy: :one_for_all
    ]

    children = [
      worker_spec(pool_config)
    ]

    Supervisor.init(children, opts)
  end

  defp worker_spec(pool_config) do
    Pooly.Specs.worker_spec(Pooly.PoolServer, [self(), pool_config])
  end
end
