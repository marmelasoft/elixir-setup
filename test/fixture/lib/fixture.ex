defmodule Fixture do
  @moduledoc "A tiny project the action's CI sets up."

  @doc "Encodes a greeting as JSON, so the project needs a dependency."
  @spec hello(String.t()) :: String.t()
  def hello(name), do: Jason.encode!(%{hello: name})
end
