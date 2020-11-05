defmodule AnubisNATS.Response do
  def ok(payload \\ nil) do
    Jason.encode!(%{
      type: :ok,
      payload: payload
    })
  end

  def error(payload \\ nil) do
    Jason.encode!(%{
      type: :error,
      payload: payload
    })
  end
end
