defmodule Blitzy do
  def run(num_workers, url) when num_workers > 0 do
    worker_fun = fn -> Blitzy.Worker.start(url, self()) end

    1..num_workers
    |> Enum.map(fn _ -> Task.async(worker_fun) end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.map(fn {_pid, result} -> result end)
    |> parse_results()
  end

  defp parse_results(results) do
    # first get results (is a list) and split it into
    # success and failures knowing that {:ok, anything} is
    # a success and anything else a failure
    {successes, _failures} =
      results
      |> Enum.split_with(fn r ->
        case r do
          {:ok, _} -> true
          _ -> false
        end
      end)

    total_workers = Enum.count(results)
    total_success = Enum.count(successes)
    total_failures = total_workers - total_success

    data =
      successes
      |> Enum.map(fn {:ok, time} -> time end)

    average_time = average(data)
    longest_time = Enum.max(data)
    shortest_time = Enum.min(data)

    IO.puts("""
    ----------
    Total Workers     :   #{total_workers}
    Successful reqs   :   #{total_success}
    Failed reqs       :   #{total_failures}
    Average(ms)       :   #{average_time}
    Longest(ms)       :   #{longest_time}
    Shortest(ms)      :   #{shortest_time}
    ----------
    """)
  end

  defp average(list) do
    sum = Enum.sum(list)

    if sum > 0 do
      sum / Enum.count(list)
    else
      0
    end
  end
end
