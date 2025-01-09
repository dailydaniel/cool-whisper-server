defmodule WhisperServer.InferenceRunner do
  @moduledoc """
  Runs inference on audio files using the initialized Whisper model.
  """

  def run_inference(audio_path) do
    result = Nx.Serving.batched_run(WhisperServer.WhisperInference.Serving, {:file, audio_path})
    result
  end
end
