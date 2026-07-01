defmodule PinterestApiWeb.AuthController do
  use PinterestApiWeb, :controller

  alias PinterestApi.Accounts
  alias PinterestApi.Accounts.Auth

  def register(conn, %{"name" => name, "email" => email, "password" => password}) do
    case Accounts.create_user(%{name: name, email: email, password: password}) do
      {:ok, user} ->
        {:ok, token} = Auth.token_for_user(user)
        json(conn, %{token: token, user: %{id: user.id, name: user.name, email: user.email}})

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {k, v}, acc -> String.replace(acc, "%{#{k}}", to_string(v)) end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Auth.login(email, password) do
      {:ok, %{user: user, token: token}} ->
        json(conn, %{token: token, user: %{id: user.id, name: user.name, email: user.email}})

      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: message})
    end
  end
end
