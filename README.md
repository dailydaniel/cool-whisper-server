# Whisper Inference Server

Whisper Inference Server is an OpenAI compatible Elixir-based HTTP server for running inference on audio files using OpenAI’s Whisper model. The server supports batching for efficient inference, CPU/GPU execution via EXLA backend, and can be configured dynamically at runtime through command-line parameters.

### Features
- Batching: Process multiple audio files simultaneously to optimize inference.
- CPU/GPU support: Choose between host (CPU) or cuda (GPU) backends for inference.
- Dynamic configuration: Configure model, batch size, timeout, and other parameters at runtime.
- Modular design: Clean architecture for easy extension and maintenance.

### Installation
1.	Elixir installation
If Elixir is not installed, follow the official guide.
2.	FFmpeg installation
The server requires FFmpeg for audio preprocessing. Install it using:
```bash
sudo apt update
sudo apt install ffmpeg
```
3. Clone the repository:
```bash
git clone git@github.com:dailydaniel/cool-whisper-server.git
cd cool-whisper-server
```
4. Fix .env if you need:
current.env:
```raw_text
DEFAULT_DEVICE_ID=0
MEMORY_FRACTION=0.9
```
5. Install dependencies:
```bash
mix deps.get
mix deps.compile
```
6. Run the server:
```bash
mix run --no-halt -- \
    --batch_size 3 \
    --batch_timeout 3000 \
    --client host \
    --model openai/whisper-tiny \
    --port 4000
```
### How to use
1. With curl:
```bash
curl -X POST -F "file=@some_audio.wav" http://localhost:4000/infer
```
2. With Python:
```python3
from openai import OpenAI

HOST = 'localhost'
PORT = 4000
client = OpenAI(api_key="None", base_url=f"http://{HOST}:{PORT}/v1/")

file_path = "some_audio.wav"
audio_file = open(file_path, "rb")
transcription = client.audio.transcriptions.create(
    model="whisper-1", file=audio_file, response_format="text"  # response format: text | json
)
```
### Configuration Parameters
- --batch_size (default: 3): Number of audio files to process in a batch.
- --batch_timeout (default: 3000): Maximum wait time (in ms) for batch formation.
- --client (default: host): Backend type for inference (host or cuda).
- --model (default: openai/whisper-tiny): Name of the Whisper model from Hugging Face Hub.
- --port (default: 4000): HTTP port to run the server.
### Using the Server
Send a POST request with an audio file to the /infer endpoint. For example:
```bash
curl -X POST -F "file=@path/to/audio.wav" http://localhost:4000/infer
```
The server will return the transcription result in JSON format.
### Contributing
Contributions, issues, and feature requests are welcome. Feel free to submit a pull request or open an issue in the repository.
