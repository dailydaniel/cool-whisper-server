defmodule WhisperServer.WhisperInference do
  use Supervisor

  @moduledoc """
  Initializes the Whisper model and sets up the serving process.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    model_name = Application.get_env(:whisper_server, :model_name, "openai/whisper-tiny")
    client = Application.get_env(:whisper_server, :client, :host)
    batch_size = Application.get_env(:whisper_server, :batch_size, 3)
    batch_timeout = Application.get_env(:whisper_server, :batch_timeout, 3000)

    Nx.global_default_backend({EXLA.Backend, client: client})

    {:ok, model} = Bumblebee.load_model({:hf, model_name})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, model_name})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, model_name})
    {:ok, generation_config} = Bumblebee.load_generation_config({:hf, model_name})

    serving = Bumblebee.Audio.speech_to_text_whisper(
      model, featurizer, tokenizer, generation_config,
      chunk_num_seconds: 30,
      defn_options: [compiler: EXLA]
    )

    children = [
      {Nx.Serving,
       serving: serving,
       name: __MODULE__.Serving,
       batch_size: batch_size,
       batch_timeout: batch_timeout}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
