defmodule AnubisNATS do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    Supervisor.init(children(), strategy: :one_for_one)
  end

  defp children() do
    [
      AnubisNATS.Connection,
      AnubisNATS.Auth.Supervisor
    ]
  end
end
