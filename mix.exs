defmodule WhisperServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :whisper_server,
      version: "0.1.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {WhisperServer.Application, []}
    ]
  end

  defp deps do
    [
      {:bumblebee, github: "elixir-nx/bumblebee"},
      {:exla, "~> 0.9.2"},
      {:nx, "~> 0.9.2"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end

  defp elixirc_paths(_env) do
    ["lib/whisper_server"]
  end
end
