defmodule WhisperServerTest do
  use ExUnit.Case
  doctest WhisperServer

  test "greets the world" do
    assert WhisperServer.hello() == :world
  end
end
