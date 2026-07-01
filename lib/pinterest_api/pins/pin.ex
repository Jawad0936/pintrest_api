defmodule PinterestApi.Pins.Pin do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "pins" do
    field :description, :string
    field :category, :string
    field :status, :string, default: "pending"
    field :deadline, :utc_datetime_usec
    field :completed_at, :utc_datetime_usec

    belongs_to :user, PinterestApi.Accounts.User
    belongs_to :board, PinterestApi.Boards.Board
    has_many :logs, PinterestApi.Logs.Log

    timestamps(type: :utc_datetime_usec)
  end

  @statuses ~w(pending completed)

  def changeset(pin, attrs) do
    pin
    |> cast(attrs, [:description, :category, :status, :deadline, :completed_at, :user_id, :board_id])
    |> validate_required([:description, :category, :user_id])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:board_id)
  end

  def complete_changeset(pin) do
    pin
    |> change(status: "completed", completed_at: DateTime.utc_now())
  end
end
