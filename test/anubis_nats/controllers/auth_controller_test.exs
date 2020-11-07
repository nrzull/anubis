defmodule AnubisNATS.AuthControllerTest do
  use Anubis.RepoCase
  use ExUnit.Case

  alias AnubisNATS.AuthController

  describe "auth.login" do
    @auth_login_valid %{name: "john", password: "abcd", meta: %{hwid: "cfGqwdX"}}

    test "it makes log-in successful with @auth_login_valid" do
      {:ok, _} = Anubis.AuthAction.register(@auth_login_valid)

      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_valid)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload

      {:ok, %{}} = Anubis.JWTService.verify_and_validate(payload)
    end

    test "it returns error when name is not given" do
      body = %{@auth_login_valid | name: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "it returns error when password is not given" do
      body = %{@auth_login_valid | password: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "it returns error when name and password are not given" do
      body = %{@auth_login_valid | password: nil, name: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "it returns error when meta is not given" do
      body = %{@auth_login_valid | meta: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "it returns error when account with given name is not exists" do
      body = %{@auth_login_valid | name: "jane"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "it returns error when password doesn't match" do
      {:ok, _} = Anubis.AuthAction.register(@auth_login_valid)

      body = %{@auth_login_valid | password: @auth_login_valid[:password] <> "1"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end
  end
end
