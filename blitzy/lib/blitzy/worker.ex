defmodule Blitzy.Worker do
  use Timex

  require Logger

  def start(url, getter_func \\ &HTTPoison.get/1) do
    IO.puts("Running on #node-#{node()}")

    # Duration.measure returns a tuple with the elapsedtime
    # for the executed function and the function return value
    {timestamp, response} = Duration.measure(fn -> getter_func.(url) end)

    handle_response({Duration.to_milliseconds(timestamp), response})
  end

  defp handle_response({msecs, {:ok, %HTTPoison.Response{status_code: code}}})
       when code >= 200 and code <= 304 do
    Logger.info("worker [#{node()}-#{inspect(self())}] completed in #{msecs} ms")

    {:ok, msecs}
  end

  defp handle_response({_msecs, {:error, reason}}) do
    Logger.info("worker [#{node()}-#{inspect(self())}] error due to #{inspect(reason)}")

    {:error, reason}
  end

  defp handle_response({_msecs, _}) do
    Logger.info("worker [#{node()}-#{inspect(self())}] unknown error")

    {:error, :unknown}
  end
end
