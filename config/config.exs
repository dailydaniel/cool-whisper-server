import Config

env_file = ".env"

if File.exists?(env_file) do
  File.read!(env_file)
  |> String.split("\n", trim: true)
  |> Enum.each(fn line ->
    case String.split(line, "=", parts: 2) do
      [key, value] -> System.put_env(String.trim(key), String.trim(value))
      _ -> :ok
    end
  end)
else
  IO.puts("Warning: #{env_file} not found.")
end

config :exla,
  clients: [
    host: [platform: :host],
    cuda: [
      platform: :cuda,
      default_device_id: String.to_integer(System.get_env("DEFAULT_DEVICE_ID", "0")),
      memory_fraction: String.to_float(System.get_env("MEMORY_FRACTION", "0.9"))
    ]
  ]
