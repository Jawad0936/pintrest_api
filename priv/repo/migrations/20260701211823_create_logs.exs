defmodule PinterestApi.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string, null: false
      add :system, :boolean, null: false, default: false
      add :pin_id, references(:pins, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:logs, [:pin_id])
    create index(:logs, [:inserted_at])
  end
end
