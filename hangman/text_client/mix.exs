defmodule TextClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :text_client,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # (2)
      # This is how we instruct the runtime to NOT start the hangman
      # application and only load the code.
      included_applications: [:hangman],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # (1)
      # Here we tell the runtime that we depend on hangman
      # and as Hangman is an application the runtime starts
      # all the applications that we depend on by default.
      # *BUT* we do not want to start hangman servers in the client.
      # we just want the code to be loaded because we need the API
      # to talk to the server.
      # See (2)
      {:hangman, path: "../hangman/"}
    ]
  end
end
