defmodule AnubisNATS.AuthController.AuthLoginTest do
  use Anubis.RepoCase
  use ExUnit.Case
  import Ecto.Query
  alias AnubisNATS.AuthController
  alias Anubis.Schemas.Account
  alias Anubis.{JWTService, AuthService}

  @valid_via_name %{name: "john", via: "name", password: "abcdabcd", meta: %{hwid: "cfGqwdX"}}

  @valid_via_email %{
    email: "john@example.com",
    via: "email",
    password: "abcdabcd",
    meta: %{hwid: "cfGqwdX"}
  }

  @valid_via_phone %{
    phone: "+12345678901",
    via: "phone",
    password: "abcdabcd",
    meta: %{hwid: "cfGqwdX"}
  }

  describe "auth.login via name" do
    test "it makes log-in successful with @valid_via_name" do
      {:ok, _} = AuthService.register(:name, @valid_via_name)

      body = @valid_via_name
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "new_token", "token" => token, "claims" => claims} = payload

      assert is_map(claims)

      assert is_bitstring(token)

      {:ok, %{}} = Anubis.JWTService.verify_and_validate(token)
    end

    test "it returns error when name is not given" do
      body = %{@valid_via_name | name: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when password is not given" do
      body = %{@valid_via_name | password: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when name and password are not given" do
      body = %{@valid_via_name | password: nil, name: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when meta is not given" do
      body = %{@valid_via_name | meta: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when account with given name is not exists" do
      body = %{@valid_via_name | name: "jane"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "no_account"} = payload
    end

    test "it returns error when password doesn't match" do
      {:ok, _} = AuthService.register(:name, @valid_via_name)

      body = %{@valid_via_name | password: @valid_via_name[:password] <> "1"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "invalid_password"} = payload
    end
  end

  describe "auth.login via email" do
    test "it makes log-in successful with @valid_via_email" do
      {:ok, _} = AuthService.register(:email, @valid_via_email)

      body = @valid_via_email
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "new_token", "token" => token, "claims" => claims} = payload

      assert is_map(claims)

      assert is_bitstring(token)

      {:ok, %{}} = Anubis.JWTService.verify_and_validate(token)
    end

    test "it returns error when email is not given" do
      body = %{@valid_via_email | email: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when password is not given" do
      body = %{@valid_via_email | password: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when email and password are not given" do
      body = %{@valid_via_email | password: nil, email: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when meta is not given" do
      body = %{@valid_via_email | meta: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when account with given email is not exists" do
      body = %{@valid_via_email | email: "jane@gma.com"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "no_account"} = payload
    end

    test "it returns error when password doesn't match" do
      {:ok, _} = AuthService.register(:email, @valid_via_email)

      body = %{@valid_via_email | password: @valid_via_email[:password] <> "1"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "invalid_password"} = payload
    end
  end

  describe "auth.login via phone" do
    test "it makes log-in successful with @valid_via_phone" do
      {:ok, _} = AuthService.register(:phone, @valid_via_phone)

      body = @valid_via_phone
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "new_token", "token" => token, "claims" => claims} = payload

      assert is_map(claims)

      assert is_bitstring(token)

      {:ok, %{}} = Anubis.JWTService.verify_and_validate(token)
    end

    test "it returns error when phone is not given" do
      body = %{@valid_via_phone | phone: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when password is not given" do
      body = %{@valid_via_phone | password: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when phone and password are not given" do
      body = %{@valid_via_phone | password: nil, phone: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when meta is not given" do
      body = %{@valid_via_phone | meta: nil}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      %{"kind" => "invalid_data"} = payload
    end

    test "it returns error when account with given phone is not exists" do
      body = %{@valid_via_phone | phone: "+09876543212"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "no_account"} = payload
    end

    test "it returns error when password doesn't match" do
      {:ok, _} = AuthService.register(:phone, @valid_via_phone)

      body = %{@valid_via_phone | password: @valid_via_phone[:password] <> "1"}
      params = %{topic: "auth.login", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "error", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"kind" => "invalid_password"} = payload
    end
  end
end
