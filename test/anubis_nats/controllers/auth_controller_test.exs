defmodule AnubisNATS.AuthControllerTest do
  use Anubis.RepoCase
  use ExUnit.Case
  import Ecto.Query
  alias AnubisNATS.AuthController
  alias Anubis.Schemas.Account

  describe "auth.login" do
    @auth_login_valid %{name: "john", password: "abcd", meta: %{hwid: "cfGqwdX"}}

    test "it makes log-in successful with @auth_login_valid" do
      {:ok, _} = Anubis.AuthAction.register(@auth_login_valid)

      body = @auth_login_valid
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_bitstring(payload)

      {:ok, %{}} = Anubis.JWTService.verify_and_validate(payload)
    end

    test "it returns error when name is not given" do
      body = %{@auth_login_valid | name: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_bitstring(payload)
    end

    test "it returns error when password is not given" do
      body = %{@auth_login_valid | password: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_bitstring(payload)
    end

    test "it returns error when name and password are not given" do
      body = %{@auth_login_valid | password: nil, name: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_bitstring(payload)
    end

    test "it returns error when meta is not given" do
      body = %{@auth_login_valid | meta: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_bitstring(payload)
    end

    test "it returns error when account with given name is not exists" do
      body = %{@auth_login_valid | name: "jane"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_bitstring(payload)
    end

    test "it returns error when password doesn't match" do
      {:ok, _} = Anubis.AuthAction.register(@auth_login_valid)

      body = %{@auth_login_valid | password: @auth_login_valid[:password] <> "1"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_bitstring(payload)
    end
  end

  describe "auth.register" do
    @auth_register_valid %{name: "john", password: "abcd", meta: %{hwid: "cfGqwdX"}}

    test "it creates an account with @auth_register_valid" do
      body = @auth_register_valid
      params = %{topic: "auth.register", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_bitstring(payload)

      assert Anubis.Repo.exists?(from(a in Account, where: a.id == ^payload))
    end
  end
end
