defmodule Blitzy.Caller do
  def start(num_workers, url) do
    # need this for spawn:
    # self() inside spawned function returns
    # child PID and we need caller PID
    me = self()

    1..num_workers
    |> Enum.map(fn _ -> spawn(fn -> Blitzy.Worker.start(url, me) end) end)
    |> Enum.map(fn _ ->
      receive do
        x ->
          x
      end
    end)
  end
end
