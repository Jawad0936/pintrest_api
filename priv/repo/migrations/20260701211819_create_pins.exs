defmodule PinterestApi.Repo.Migrations.CreatePins do
  use Ecto.Migration

  def change do
    create table(:pins, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string, null: false
      add :category, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :deadline, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :board_id, references(:boards, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:pins, [:user_id])
    create index(:pins, [:board_id])
    create index(:pins, [:status])
    create index(:pins, [:inserted_at])
  end
end
