defmodule ProtoBotTest do
  use ExUnit.Case
  doctest ProtoBot

  test "greets the world" do
    assert ProtoBot.hello() == :world
  end
end
