defmodule Pooly.Server do
  @moduledoc """
   This server is gonna be simplified as the new Pooly.PoolServer
   will be the one taking the decisions for each pool
  """
  use GenServer

  ######
  # API
  ######

  def start_link(pools_config) do
    # As we only have one PoolsSupervisor we only need one Server
    # so we can make it a named process
    GenServer.start_link(__MODULE__, pools_config, name: __MODULE__)
  end

  def checkout(pool_name, block, timeout) do
    # GenServer.call(:"#{pool_name}Server", {:checkout, block), timeout)
    Pooly.PoolServer.checkout(pool_name, block, timeout)
  end

  def checkin(pool_name, worker_pid) do
    # GenServer.cast(:"#{pool_name}Server", {:checkin, worker_pid})
    Pooly.PoolServer.checkin(pool_name, worker_pid)
  end

  def status(pool_name) do
    # GenServer.call(:"#{pool_name}Server", :status)
    Pooly.PoolServer.status(pool_name)
  end

  ############
  # CallBacks
  ############

  def init(pools_config) when is_list(pools_config) do
    pools_config
    |> Enum.each(fn pool_config ->
      send(self(), {:start_pool, pool_config})
    end)

    {:ok, pools_config}
  end

  def handle_info({:start_pool, pool_config}, state) do
    {:ok, _pool_sup} = Supervisor.start_child(Pooly.PoolsSupervisor, supervisor_spec(pool_config))
    {:noreply, state}
  end

  ####################
  # Private Functions
  ####################

  defp supervisor_spec(pool_config) do
    opts = [
      id: :"#{pool_config[:name]}Supervisor"
    ]

    Pooly.Specs.supervisor_spec(Pooly.PoolSupervisor, [pool_config], opts)
  end
end
