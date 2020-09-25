defmodule AmqpReader.MixProject do
  use Mix.Project

  def project do
    [
      app: :amqp_reader,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: AmqpReader.CLI, path: "bin/amqp_reader"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:lager, :logger, :amqp]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:amqp, "~> 1.5"}
    ]
  end
end
