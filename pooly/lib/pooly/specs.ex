defmodule Pooly.Specs do
  def worker_spec(module) when is_atom(module) do
    worker_spec(module, :start_link, [], [])
  end

  def worker_spec(module, args) when is_list(args) and is_atom(module) do
    worker_spec(module, :start_link, args, [])
  end

  def worker_spec(module, args, opts) when is_list(opts) and is_list(args) and is_atom(module) do
    worker_spec(module, :start_link, args, opts)
  end

  def worker_spec(module, function, args, opts) do
    default_spec = %{
      id: module,
      start: {module, function, args},
      restart: :permanent,
      shutdown: 5_000,
      type: :worker,
      modules: [module]
    }

    Map.merge(default_spec, Map.new(opts))
  end

  def supervisor_spec(module) when is_atom(module) do
    supervisor_spec(module, :start_link, [], [])
  end

  def supervisor_spec(module, args) when is_list(args) and is_atom(module) do
    supervisor_spec(module, :start_link, args, [])
  end

  def supervisor_spec(module, args, opts)
      when is_list(opts) and is_list(args) and is_atom(module) do
    supervisor_spec(module, :start_link, args, opts)
  end

  def supervisor_spec(module, function, args, opts) do
    default_spec = %{
      id: module,
      start: {module, function, args},
      # default
      restart: :permanent,
      # default for :supervisor
      shutdown: :infinity,
      type: :supervisor,
      modules: [module]
    }

    Map.merge(default_spec, Map.new(opts))
  end
end
