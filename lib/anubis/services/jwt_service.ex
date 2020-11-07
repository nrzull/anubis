defmodule Anubis.JWTService do
  use Joken.Config

  def expired?(params) do
    %{"exp" => expired_at} = params
    now = System.os_time(:second)
    diff = expired_at - now

    diff <= 0
  end

  def check_for_corrupted_meta(%{token_meta: token_meta, meta: meta, keys: keys}) do
    target =
      Enum.reduce(keys, %{}, fn key, acc ->
        Map.put(acc, key, Map.get(token_meta, key))
      end)

    error_keys =
      Enum.reduce(target, [], fn {k, v}, acc ->
        case Map.get(meta, String.to_atom(k)) == v || Map.get(meta, k) == v do
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
