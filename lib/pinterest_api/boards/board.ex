defmodule PinterestApi.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "boards" do
    field :name, :string
    field :category, :string

    belongs_to :user, PinterestApi.Accounts.User
    has_many :pins, PinterestApi.Pins.Pin

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :category, :user_id])
    |> validate_required([:name, :category, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
