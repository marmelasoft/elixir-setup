defmodule Fixture do
  @moduledoc "A tiny project the action's CI sets up."

  @doc "Encodes a greeting as JSON, so the project needs a dependency."
  @spec hello(String.t()) :: String.t()
  def hello(name), do: Jason.encode!(%{hello: name})

  @doc "Solves a SAT problem, so the project needs a NIF."
  @spec solve([[integer()]]) :: {:ok, [integer()]} | {:error, atom()}
  def solve(clauses), do: Picosat.solve(clauses)
end
