defmodule WhisperServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :whisper_server,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WhisperServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bumblebee, github: "elixir-nx/bumblebee"},
      {:exla, "~> 0.9.2"},
      {:nx, "~> 0.9.2"},
      {:plug_cowboy, "~> 2.5"} # Для HTTP-сервера
    ]
  end
end
