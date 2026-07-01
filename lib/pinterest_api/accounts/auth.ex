defmodule PinterestApi.Accounts.Auth do
  alias PinterestApi.Accounts
  alias PinterestApi.Guardian

  def login(email, password) do
    with {:ok, user} <- Accounts.authenticate(email, password),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      {:ok, %{user: user, token: token}}
    else
      {:error, :invalid_password} -> {:error, "Invalid credentials"}
      {:error, :not_found} -> {:error, "Invalid credentials"}
      error -> error
    end
  end

 def token_for_user(user) do
  case Guardian.encode_and_sign(user) do
    {:ok, token, _claims} -> {:ok, token}
    error -> error
  end
end
end
