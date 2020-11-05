defmodule AnubisNATS.AuthControllerTest do
  use ExUnit.Case, async: true

  setup do
    pid = Process.whereis(AnubisNATS.name())
    {:ok, pid: pid}
  end

  test "lmao", %{pid: pid} do
    assert Process.alive?(pid)

    case Gnat.request(pid, "auth.login", "{}", receive_timeout: 1000) do
      {:ok, _} -> nil
      error -> refute error
    end
  end
end
