defmodule CauchyTest do
  use ExUnit.Case
  doctest Cauchy

  test "greets the world" do
    assert Cauchy.hello() == :world
  end
end
