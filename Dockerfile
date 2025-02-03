FROM ghcr.io/livebook-dev/livebook:0.14.7-cuda12

RUN apt-get update && \
    apt-get install -y ffmpeg git build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV EXLA_TARGET=cuda

COPY mix.exs ./
RUN mix deps.get && mix deps.compile

COPY . .

RUN mix compile

EXPOSE 4000

ENTRYPOINT ["mix", "run", "--no-halt", "--"]

CMD ["--batch_size=3", "--batch_timeout=3000", "--client=host", "--model=openai/whisper-tiny", "--port=4000"]
