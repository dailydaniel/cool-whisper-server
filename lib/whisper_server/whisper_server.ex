defmodule WhisperServer do
  use Plug.Router
  require Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  post "/infer" do
    handle_request(conn)
  end

  post "/v1/audio/transcriptions" do
    model = conn.params["model"] || "whisper-1"
    response_format = conn.params["response_format"] || "json"

    if model != "whisper-1" do
      send_resp(conn, 400, Jason.encode!(%{error: "Unsupported model"}))
    else
      upload = conn.params["file"]

      case File.read(upload.path) do
        {:ok, file_bytes} ->

          filename = "uploaded_#{System.unique_integer([:positive])}_#{upload.filename}"
          temp_path = Path.join("uploads", filename)

          File.mkdir_p!("uploads")

          case File.write(temp_path, file_bytes) do
            :ok ->
              try do
                result = WhisperServer.InferenceRunner.run_inference(temp_path)
                Logger.info("Inference result: #{inspect(result)}")
                result_text = extract_text_from_infer_response(result)
                Logger.info("Extracted text: #{result_text}")

                case response_format do
                  "text" ->
                    conn
                    |> put_resp_header("Content-Disposition", "attachment; filename=result.txt")
                    |> send_resp(200, result_text)

                  "json" ->
                    conn
                    |> put_resp_header("Content-Disposition", "attachment; filename=result.json")
                    |> send_resp(200, Jason.encode!(%{text: result_text}))

                  _ ->
                    send_resp(conn, 200, Jason.encode!(result))
                end
              after
                File.rm(temp_path)
              end

            {:error, reason} ->
              send_resp(conn, 500, Jason.encode!(%{error: "Failed to save file: #{reason}"}))
          end

        {:error, reason} ->
          send_resp(conn, 500, Jason.encode!(%{error: "Failed to read file: #{reason}"}))
      end
    end
  end

  post "/v1/audio/translations" do
    send_resp(conn, 200, Jason.encode!(%{}))
  end

  get "/health" do
    send_resp(conn, 200, Jason.encode!(%{status: "ok"}))
  end

  get "/v1/models" do
    send_resp(conn, 200, Jason.encode!(["whisper-1"]))
  end

  get "/v1/models/:model" do
    model = conn.params["model"]
    if model == "whisper-1" do
      send_resp(conn, 200, Jason.encode!(%{name: "whisper-1"}))
    else
      send_resp(conn, 404, Jason.encode!(%{error: "Model not found"}))
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp extract_text_from_infer_response(response) do
    response
    |> Map.get(:chunks, [])
    |> Enum.map(& &1[:text])
    |> Enum.join(" ")
    |> String.trim()
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
