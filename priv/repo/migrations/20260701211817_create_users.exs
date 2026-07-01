defmodule PinterestApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false
      add :avatar_url, :string
      add :password_hash, :string
      add :google_id, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:google_id])
  end
end
