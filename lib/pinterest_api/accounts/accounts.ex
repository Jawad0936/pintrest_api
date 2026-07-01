defmodule PinterestApi.Accounts do
  import Ecto.Query, warn: false
  alias PinterestApi.Repo
  alias PinterestApi.Accounts.User

  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_google_id(google_id) when is_binary(google_id) do
    Repo.get_by(User, google_id: google_id)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_by_google(attrs) do
    case get_user_by_google_id(attrs.google_id) do
      nil -> create_user(attrs)
      user -> {:ok, user}
    end
  end

  def authenticate(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Pbkdf2.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :invalid_password}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
