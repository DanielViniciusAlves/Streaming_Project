defmodule StreamingTest do
  use ExUnit.Case
  doctest Streaming

  test "greets the world" do
    assert Streaming.hello() == :world
  end
end
