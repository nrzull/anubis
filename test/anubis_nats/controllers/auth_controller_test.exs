defmodule AnubisNATS.AuthControllerTest do
  use ExUnit.Case, async: true
  alias AnubisNATS.AuthController

  setup do
    pid = Process.whereis(AnubisNATS.name())
    {:ok, pid: pid}
  end

  describe "auth.login" do
    @auth_login_valid %{name: "john", password: "abcd"}
    @auth_login_invalid_1 %{@auth_login_valid | name: nil}
    @auth_login_invalid_2 %{@auth_login_valid | password: nil}
    @auth_login_invalid_3 %{@auth_login_valid | password: nil, name: nil}

    test "@auth_login_valid :: returns ok with payload true", %{pid: pid} do
      assert Process.alive?(pid)
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_valid)}
      {:reply, <<_::binary>> = response} = AuthController.request(params)
      assert Jason.decode!(response) == %{"type" => "ok", "payload" => true}
    end

    test "@auth_login_invalid_1 :: returns error with payload false", %{pid: pid} do
      assert Process.alive?(pid)
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_1)}
      {:reply, <<_::binary>> = response} = AuthController.request(params)
      assert Jason.decode!(response) == %{"type" => "error", "payload" => false}
    end

    test "@auth_login_invalid_2 :: returns error with payload false", %{pid: pid} do
      assert Process.alive?(pid)
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_2)}
      {:reply, <<_::binary>> = response} = AuthController.request(params)
      assert Jason.decode!(response) == %{"type" => "error", "payload" => false}
    end

    test "@auth_login_invalid_3 :: returns error with payload false", %{pid: pid} do
      assert Process.alive?(pid)
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_3)}
      {:reply, <<_::binary>> = response} = AuthController.request(params)
      assert Jason.decode!(response) == %{"type" => "error", "payload" => false}
    end
  end
end
