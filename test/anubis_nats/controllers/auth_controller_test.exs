defmodule AnubisNATS.AuthControllerTest do
  use ExUnit.Case, async: true

  setup do
    pid = Process.whereis(AnubisNATS.name())
    {:ok, pid: pid}
  end

  describe "auth.login" do
    test "returns 'true'", %{pid: pid} do
      assert Process.alive?(pid)

      params = %{topic: "auth.login", body: Jason.encode!(%{name: "john", password: "abcd"})}

      {:reply, <<_::binary>> = response} = AnubisNATS.AuthController.request(params)

      assert response == "true"
    end
  end
end
