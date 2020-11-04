defmodule AnubisNATS.Endpoint do
  def start_link(args) do
    Gnat.start_link(args, name: __MODULE__)
  end

  def child_spec(_) do
    opts = [
      %{
        host: Application.fetch_env!(:anubis, :host),
        port: Application.fetch_env!(:anubis, :port)
      }
    ]

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts}
    }
  end
end
