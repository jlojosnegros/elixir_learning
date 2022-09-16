defmodule ThySupervisor do
  @moduledoc """
  Documentation for `ThySupervisor`.
  """

  use GenServer

  ##########
  # API
  ##########

  def start_link(child_spec_list) do
    # recordamos que el segundo parametro es lo que se le pasa al init/1
    GenServer.start_link(__MODULE__, [child_spec_list])
  end

  def start_child(supervisor, child_spec) do
    GenServer.call(supervisor, {:start_child, child_spec})
  end

  def terminate_child(supervisor, pid) when is_pid(pid) do
    GenServer.call(supervisor, {:terminate_child, pid})
  end

  def restart_child(supervisor, pid, child_spec) when is_pid(pid) do
    GenServer.call(supervisor, {:restart_child, pid, child_spec})
  end

  def count_children(supervisor) do
    GenServer.call(supervisor, {:count_child})
  end

  def which_children(supervisor) do
    GenServer.call(supervisor, {:which_child})
  end

  ####################
  # Callback Functions
  ####################

  def init([child_spec_list]) do
    # Evita que el proceso se muera cuando llegue
    # un EXIT de un child process si no que lo
    # convierta en un mensaje.
    Process.flag(:trap_exit, true)

    # start_children lanza los procesos especificados
    # devuelve por cada uno una tupla con
    # {pid, child_spec}
    # Esto se lo pasamos a un HashDict
    # de manera que usamos el pid como clave
    # y el child_spec como valor.
    state =
      child_spec_list
      |> start_children
      |> Enum.into(Map.new())

    {:ok, state}
  end

  def handle_call({:start_child, child_spec}, _from, state) do
    case start_child(child_spec) do
      {:ok, pid} ->
        new_state = state |> Map.put(pid, child_spec)
        {:reply, {:ok, pid}, new_state}

      :error ->
        {:reply, {:error, "error starting child"}, state}
    end
  end

  def handle_call({:terminate_child, pid}, _from, state) do
    case terminate_child(pid) do
      :ok ->
        new_state = state |> Map.delete(pid)
        {:reply, :ok, new_state}

      :error ->
        {:reply, {:error, "error terminating child"}, state}
    end
  end

  def handle_call({:restart_child, pid, child_spec}, _from, state) do
    # Buscamos el pid en el estado
    case Map.fetch(state, pid) do
      # Si lo encontramos ...
      {:ok, _old_child_spec} ->
        # ... intentamos reiniciarlo ...
        case restart_child(pid, child_spec) do
          # ... si lo conseguimos ...
          {:ok, {new_pid, child_spec}} ->
            new_state =
              state
              # borramos el anterior pid
              |> Map.delete(pid)
              # metemos el nuevo
              |> Map.put(new_pid, child_spec)

            # y contestamos que todo OK
            {:reply, {:ok, pid}, new_state}

          :error ->
            {:reply, {:error, "error restarting child"}, state}
        end

      # ... si no encontramos el PID .. no hay nada que reiniciar
      # pero devolvemos ok para seguir sin problemas.
      _ ->
        {:reply, :ok, state}
    end
  end

  def handle_call({:count_child}, _from, state) do
    {:reply, Dict.size(state), state}
  end

  def handle_call({:which_child}, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, pid, :killed}, state) do
    # No deberia de hacer falta porque se supone
    # que lo hemos borrado en el terminate_child
    # pero por si es matado por otras fuentes.
    new_state = state |> Map.delete(pid)
    {:noreply, new_state}
  end

  ####################
  # Private Functions
  ####################

  defp start_child({mod, fun, args}) do
    case apply(mod, fun, args) do
      pid when is_pid(pid) ->
        Process.link(pid)
        {:ok, pid}

      _ ->
        :error
    end
  end

  defp start_children([child_spec | rest]) do
    case start_child(child_spec) do
      {:ok, pid} ->
        [{pid, child_spec} | start_children(rest)]

      :error ->
        :error
    end
  end

  defp start_children([]), do: []

  defp terminate_child(pid) do
    # Esto hara que nos llegue un mensaje
    # {:EXIT, pid, :killed} que tenemos que
    # poder manejar, de ahi el handle_info
    Process.exit(pid, :kill)
    :ok
  end

  defp restart_child(pid, child_spec) when is_pid(pid) do
    case terminate_child(pid) do
      :ok ->
        case start_child(child_spec) do
          {:ok, new_pid} ->
            {:ok, {new_pid, child_spec}}

          :error ->
            :error
        end

      :error ->
        :error
    end
  end
end
