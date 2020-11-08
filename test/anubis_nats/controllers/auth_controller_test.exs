defmodule AnubisNATS.AuthControllerTest do
  use Anubis.RepoCase
  use ExUnit.Case
  import Ecto.Query
  alias AnubisNATS.AuthController
  alias Anubis.Schemas.Account
  alias Anubis.{JWTService, AuthService}

  describe "auth.login" do
    @auth_login_valid %{name: "john", password: "abcd", meta: %{hwid: "cfGqwdX"}}

    test "it makes log-in successful with @auth_login_valid" do
      {:ok, _} = AuthService.register(@auth_login_valid)

      body = @auth_login_valid
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "new_token", "token" => token, "claims" => claims} = payload

      assert is_map(claims)

      assert is_bitstring(token)

      {:ok, %{}} = Anubis.JWTService.verify_and_validate(token)
    end

    test "it returns error when name is not given" do
      body = %{@auth_login_valid | name: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when password is not given" do
      body = %{@auth_login_valid | password: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when name and password are not given" do
      body = %{@auth_login_valid | password: nil, name: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when meta is not given" do
      body = %{@auth_login_valid | meta: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when account with given name is not exists" do
      body = %{@auth_login_valid | name: "jane"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "no_account"} = payload
    end

    test "it returns error when password doesn't match" do
      {:ok, _} = AuthService.register(@auth_login_valid)

      body = %{@auth_login_valid | password: @auth_login_valid[:password] <> "1"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "invalid_password"} = payload
    end
  end

  describe "auth.register" do
    @auth_register_valid %{name: "john", password: "abcd", meta: %{hwid: "cfGqwdX"}}

    test "it creates an account with @auth_register_valid" do
      body = @auth_register_valid
      params = %{topic: "auth.register", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"account_id" => id} = payload

      assert is_bitstring(id)

      assert Anubis.Repo.exists?(from(a in Account, where: a.id == ^id))
    end
  end

  describe "auth.verify_token" do
    @valid_meta %{hwid: "cfGqwdX"}

    test "it should success without any meta and keys" do
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => %{}})
      body = %{token: token, meta: %{}, keys: []}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      refute payload
    end

    test "it should success with correct meta" do
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => @valid_meta})
      body = %{token: token, meta: @valid_meta, keys: ["hwid"]}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      refute payload
    end

    test "it should success with correct meta and unknown keys" do
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => @valid_meta})
      body = %{token: token, meta: @valid_meta, keys: ["ADASD"]}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      refute payload
    end

    test "it should success with incorrect meta and without keys" do
      incorrect_meta = %{@valid_meta | hwid: @valid_meta[:hwid] <> "1"}
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => @valid_meta})
      body = %{token: token, meta: incorrect_meta, keys: ["ADASD"]}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      refute payload
    end

    test "it should fail with incorrect meta and with keys" do
      incorrect_meta = %{@valid_meta | hwid: @valid_meta[:hwid] <> "1"}
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => @valid_meta})
      body = %{token: token, meta: incorrect_meta, keys: ["hwid"]}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "corrupted_meta", "keys" => ["hwid"]} = payload
    end
  end
end
