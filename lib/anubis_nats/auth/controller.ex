defmodule AnubisNATS.Auth.Controller do
  use Gnat.Server

  def request(%{topic: "auth.login", body: body}) do
    {:reply, body}
  end

  # def error(%{gnat: gnat, reply_to: reply_to}, _error) do
  #   Gnat.pub(gnat, reply_to, "Something went wrong and I can't handle your request")
  # end
end
