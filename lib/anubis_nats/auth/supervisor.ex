defmodule AnubisNATS.Auth.Supervisor do
  def start_link() do
    Gnat.ConsumerSupervisor.start_link(
      %{
        connection_name: :nats_conn,
        module: AnubisNATS.Auth.Controller,
        subscription_topics: [
          %{topic: "auth.*"}
        ]
      },
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
end
