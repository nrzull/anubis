defmodule Anubis.CryptService do
  def hash(password) do
    Bcrypt.hash_pwd_salt(password)
  end

  def valid?(raw, hash) do
    Bcrypt.verify_pass(raw, hash)
  end
end
