defmodule WhisperServer do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  post "/infer" do
    handle_request(conn)
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp handle_request(conn) do
    upload = conn.params["file"]

    temp_path = decode_audio_from_body(upload)

    try do
      result = WhisperServer.InferenceRunner.run_inference(temp_path)

      send_resp(conn, 200, Jason.encode!(result))
    after
      File.rm(temp_path)
    end
  end

  defp decode_audio_from_body(%Plug.Upload{path: uploaded_file_path, filename: filename}) do
    unique_name = "uploaded_#{System.unique_integer([:positive])}_#{filename}"
    temp_path = Path.join("uploads", unique_name)

    File.mkdir_p!("uploads")

    File.cp!(uploaded_file_path, temp_path)

    temp_path
  end
end
