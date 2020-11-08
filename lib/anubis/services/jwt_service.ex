defmodule Anubis.JWTService do
  use Joken.Config

  def expired?(params) do
    %{"exp" => expired_at} = params
    now = System.os_time(:second)
    diff = expired_at - now

    diff <= 0
  end

  def gen_claims(%{id: id, meta: meta}) do
    %{"id" => id, "meta" => meta}
  end

  def refresh_token(%{token_meta: token_meta}) do
    id = Map.get(token_meta, "id") || Map.get(token_meta, :id)
    meta = Map.get(token_meta, "meta") || Map.get(token_meta, :meta)

    generate_and_sign(gen_claims(%{id: id, meta: meta}))
  end

  def check_for_corrupted_meta(%{token_meta: token_meta, meta: meta, keys: keys}) do
    target =
      Enum.reduce(keys, %{}, fn key, acc ->
        value = Map.get(token_meta, key) || Map.get(token_meta, String.to_atom(key))
        Map.put(acc, key, value)
      end)

    error_keys =
      Enum.reduce(target, [], fn {k, v}, acc ->
        value = Map.get(meta, k) || Map.get(meta, String.to_atom(k))

        case value == v do
          false ->
            [k | acc]

          true ->
            acc
        end
      end)

    case List.first(error_keys) do
      nil -> nil
      _ -> {token_meta, meta, error_keys}
    end
  end
end
