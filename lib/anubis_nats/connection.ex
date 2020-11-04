defmodule AnubisNATS.Connection do
  def start_link() do
    Gnat.ConnectionSupervisor.start_link(
      %{name: name(), connection_settings: connection_settings()},
      name: __MODULE__
    )
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def name do
    :nats_conn
  end

  defp connection_settings do
    [
      %{
        host: Application.fetch_env!(:anubis, :host),
        port: Application.fetch_env!(:anubis, :port)
      }
    ]
  end
end
