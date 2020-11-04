defmodule AnubisTest do
  use ExUnit.Case
  doctest Anubis

  test "greets the world" do
    assert Anubis.hello() == :world
  end
end
