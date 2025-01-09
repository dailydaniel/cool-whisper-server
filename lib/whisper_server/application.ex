defmodule WhisperServer.Application do
  use Application

  def start(_type, _args) do
    # Разбираем аргументы командной строки
    args = parse_args(System.argv())

    # Передаём параметры в другие модули через Application.put_env
    Application.put_env(:whisper_server, :model_name, args[:model])
    Application.put_env(:whisper_server, :client, String.to_atom(args[:client]))
    Application.put_env(:whisper_server, :batch_size, args[:batch_size])
    Application.put_env(:whisper_server, :batch_timeout, args[:batch_timeout])
    Application.put_env(:whisper_server, :port, args[:port])

    # Настраиваем супервизоры
    children = [
      WhisperServer.WhisperInference,
      {Plug.Cowboy, scheme: :http, plug: WhisperServer, options: [port: args[:port]]}
    ]

    opts = [strategy: :one_for_one, name: WhisperServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp parse_args(argv) do
    OptionParser.parse!(argv,
      switches: [
        batch_size: :integer,
        batch_timeout: :integer,
        client: :string,
        model: :string,
        port: :integer
      ],
      aliases: [
        b: :batch_size,
        t: :batch_timeout,
        c: :client,
        m: :model,
        p: :port
      ]
    )
    |> elem(0)
    |> Enum.into(%{
      batch_size: 3,                # Размер батча по умолчанию
      batch_timeout: 3000,          # Тайм-аут батча по умолчанию
      client: "host",               # Бекенд по умолчанию
      model: "openai/whisper-tiny", # Модель по умолчанию
      port: 4000                    # Порт по умолчанию
    })
  end
end