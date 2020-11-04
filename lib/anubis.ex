defmodule Anubis do
  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: __MODULE__]

    Supervisor.start_link(children(), opts)
  end

  defp children() do
    [AnubisNATS]
  end
end
