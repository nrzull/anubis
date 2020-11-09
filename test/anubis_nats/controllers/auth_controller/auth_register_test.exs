defmodule AnubisNATS.AuthController.AuthRegisterTest do
  use Anubis.RepoCase
  use ExUnit.Case
  import Ecto.Query
  alias AnubisNATS.AuthController
  alias Anubis.Schemas.Account
  alias Anubis.{JWTService, AuthService}

  describe "auth.register via name" do
    @valid_via_name %{
      name: "john",
      via: "name",
      password: "abcdabcd",
      meta: %{hwid: "cfGqwdX"}
    }

    test "it creates an account with @valid_via_name" do
      body = @valid_via_name
      params = %{topic: "auth.register", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"account_id" => id} = payload

      assert is_bitstring(id)

      assert Anubis.Repo.exists?(from(a in Account, where: a.id == ^id))
    end
  end

  describe "auth.register via email" do
    @valid_via_email %{
      email: "john@example.com",
      via: "email",
      password: "abcdabcd",
      meta: %{hwid: "cfGqwdX"}
    }

    test "it creates an account with @valid_via_email" do
      body = @valid_via_email
      params = %{topic: "auth.register", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"account_id" => id} = payload

      assert is_bitstring(id)

      assert Anubis.Repo.exists?(from(a in Account, where: a.id == ^id))
    end
  end

  describe "auth.register via phone" do
    @valid_via_phone %{
      phone: "+12345678901",
      via: "phone",
      password: "abcdabcd",
      meta: %{hwid: "cfGqwdX"}
    }

    test "it creates an account with @valid_via_phone" do
      body = @valid_via_phone
      params = %{topic: "auth.register", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)

      %{"account_id" => id} = payload

      assert is_bitstring(id)

      assert Anubis.Repo.exists?(from(a in Account, where: a.id == ^id))
    end
  end
end
