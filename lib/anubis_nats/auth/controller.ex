defmodule AnubisNATS.Auth.Controller do
  use Gnat.Server

  def request(_) do
    {:reply, "unknown request"}
  end
end
