defmodule AnubisNATS.Response do
  def ok(payload \\ nil) do
    {:reply,
     Jason.encode!(%{
       type: :ok,
       payload: payload
     })}
  end

  def error(payload \\ nil) do
    {:reply,
     Jason.encode!(%{
       type: :error,
       payload: payload
     })}
  end
end
