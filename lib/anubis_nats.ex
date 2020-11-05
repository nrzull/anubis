defmodule AnubisNATS do
  use Supervisor

  def name do
    :nats_conn
  end

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    Supervisor.init(children(), strategy: :one_for_one)
  end

  defp children() do
    [connection_supervisor_child()] ++ consumer_supervisor_children()
  end

  defp connection_supervisor_child do
    {Gnat.ConnectionSupervisor,
     %{
       name: name(),
       connection_settings: [
         %{
           host: Application.fetch_env!(:anubis, :host),
           port: Application.fetch_env!(:anubis, :port)
         }
       ]
     }}
  end

  defp consumer_supervisor_children() do
    [
      {Gnat.ConsumerSupervisor,
       %{
         connection_name: name(),
         module: AnubisNATS.AuthController,
         subscription_topics: [
           %{topic: "auth.*"}
         ]
       }}
    ]
  end
end
