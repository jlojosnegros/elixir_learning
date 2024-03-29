defmodule Hangman.MixProject do
  use Mix.Project

  def project do
    [
      app: :hangman,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # To make Hangman a Service it need to be an Application first
      # here we instruct the runtime to start the application
      # with the Module and the params to start
      mod: {Hangman.Runtime.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dictionary, path: "../dictionary"},
      {:dialyxir, "~>1.0", only: [:dev], runtime: false},
      {:ex_unicode, "~>1.12", only: [:test]}
    ]
  end
end
