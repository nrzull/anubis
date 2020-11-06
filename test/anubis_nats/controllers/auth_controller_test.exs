defmodule AnubisNATS.AuthControllerTest do
  use Anubis.RepoCase
  use ExUnit.Case

  alias AnubisNATS.AuthController

  describe "auth.login" do
    @auth_login_valid %{name: "john", password: "abcd", meta: %{hwid: "cfGqwdX"}}
    @auth_login_invalid_1 %{@auth_login_valid | name: nil}
    @auth_login_invalid_2 %{@auth_login_valid | password: nil}
    @auth_login_invalid_3 %{@auth_login_valid | password: nil, name: nil}
    @auth_login_invalid_4 %{@auth_login_valid | meta: nil}
    @auth_login_invalid_5 %{name: "johna", password: "abcd", meta: %{hwid: "cfGqwdX"}}
    @auth_login_invalid_6 %{name: "johna", password: "abcdasd", meta: %{hwid: "cfGqwdX"}}

    test "@auth_login_valid :: returns ok with token payload" do
      Anubis.AuthAction.register(@auth_login_valid)

      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_valid)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload

      {:ok, %{}} = Anubis.JWTService.verify_and_validate(payload)
    end

    test "@auth_login_invalid_1 :: returns error with payload message" do
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_1)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "@auth_login_invalid_2 :: returns error with payload message" do
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_2)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "@auth_login_invalid_3 :: returns error with payload message" do
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_3)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "@auth_login_invalid_4 :: returns error with payload message" do
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_4)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "@auth_login_invalid_5 :: returns error with payload message" do
      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_5)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end

    test "@auth_login_invalid_6 :: returns error with payload message" do
      Anubis.AuthAction.register(@auth_login_invalid_5)

      params = %{topic: "auth.login", body: Jason.encode!(@auth_login_invalid_6)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      <<_::binary>> = payload
    end
  end
end
