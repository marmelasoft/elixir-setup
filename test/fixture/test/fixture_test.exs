defmodule FixtureTest do
  use ExUnit.Case, async: true

  test "hello/1 encodes a greeting" do
    assert Fixture.hello("world") == ~s({"hello":"world"})
  end

  test "solve/1 loads the NIF" do
    assert Fixture.solve([[1, 2], [-1]]) == {:ok, [-1, 2]}
  end
end
