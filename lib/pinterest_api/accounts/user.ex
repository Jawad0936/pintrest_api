defmodule PinterestApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :name, :string
    field :email, :string
    field :avatar_url, :string
    field :password_hash, :string
    field :google_id, :string
    field :password, :string, virtual: true

    has_many :pins, PinterestApi.Pins.Pin
    has_many :boards, PinterestApi.Boards.Board

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :avatar_url, :google_id, :password])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> unique_constraint(:email)
    |> unique_constraint(:google_id)
    |> maybe_hash_password()
  end

  defp maybe_hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
    end
  end
end
