defmodule Anubis.AuthAction do
  def login(%{name: name, password: password} = params) when is_map(params) do
    payload = %{"id" => name}
    Anubis.JWTService.generate_and_sign(payload)
  end
end
