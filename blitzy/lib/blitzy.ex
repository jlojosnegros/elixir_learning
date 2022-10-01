defmodule Blitzy do
  def run(num_workers, url) when num_workers > 0 do
    worker_fun = fn -> Blitzy.Worker.start(url, self()) end

    1..num_workers
    |> Enum.map(fn _ -> Task.async(worker_fun) end)
    |> Enum.map(&Task.await(&1, :infinity))
  end
end
