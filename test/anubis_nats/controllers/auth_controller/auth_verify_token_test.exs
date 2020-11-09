defmodule AnubisNATS.AuthController.AuthVerifyTokenTest do
  use Anubis.RepoCase
  use ExUnit.Case
  import Ecto.Query
  alias AnubisNATS.AuthController
  alias Anubis.Schemas.Account
  alias Anubis.{JWTService, AuthService}

  describe "auth.verify_token" do
    @valid_meta %{hwid: "cfGqwdX"}

    test "it should success without any meta and keys" do
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => %{}})
      body = %{token: token, meta: %{}, keys: []}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)
    end

    test "it should success with correct meta" do
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => @valid_meta})
      body = %{token: token, meta: @valid_meta, keys: ["hwid"]}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)
    end

    test "it should success with correct meta and unknown keys" do
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => @valid_meta})
      body = %{token: token, meta: @valid_meta, keys: ["ADASD"]}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)
    end

    test "it should success with incorrect meta and without keys" do
      incorrect_meta = %{@valid_meta | hwid: @valid_meta[:hwid] <> "1"}
      {:ok, token, _} = JWTService.generate_and_sign(%{"meta" => @valid_meta})
      body = %{token: token, meta: incorrect_meta, keys: ["ADASD"]}
      params = %{topic: "auth.verify_token", body: Jason.encode!(body)}

      {:reply, <<_::binary>> = response} = AuthController.request(params)

      %{"type" => "ok", "payload" => payload} = Jason.decode!(response)

      assert is_map(payload)
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
