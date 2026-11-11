defmodule FixtureTest do
  use ExUnit.Case, async: true

  test "hello/1 encodes a greeting" do
    assert Fixture.hello("world") == ~s({"hello":"world"})
  end
end
